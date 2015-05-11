require 'sinatra/base'
require 'fog'
require 'json'
require 'httparty'


class SensuInfo
  def self.get_clients
    sensu_url= ENV['SENSU_URL']
    begin
      #hacking this in for now to get it working in prod
      sensu_clients= JSON.parse(HTTParty.get("#{sensu_url}/clients").to_json)
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end

    server_list =[]
    sensu_clients.each do |client|
      # make each instance its own individual hash so we can access later
      server_hash = Hash.new

      #grab necessary attrs
      server_hash[:name]          = client['name'].to_s
      server_hash[:address]       = client['address'].to_s
      server_hash[:subscriptions] = client['subscriptions'].to_s
      server_hash[:timestamp]     = client['timestamp'].to_i

      # append our hash of server attrs and return the server_list
      server_list << server_hash
    end

    server_list
  end

  def self.get_events
    sensu_url= ENV['SENSU_URL']
    begin
      sensu_events= JSON.parse(HTTParty.get("#{sensu_url}/events").to_json)
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end

    events =[]
    sensu_events.each do |event|
      # make each event its own individual hash so we can access later
      event_hash = Hash.new

      #grab necessary attrs
      event_attrs=['output', 'status', 'issued', 'handlers', 'flapping',
        'occurrences', 'client', 'check', 'id', 'status_name', 'url',
        'client_silence_path', 'silence_path', 'client_silenced']
      event_attrs.each do |attr|
        event_hash["#{attr}"] = event["#{attr}"].to_s
      end

      # append our hash of server attrs and return the server_list
      events << event_hash
    end

    events
  end

  def self.get_checks
    sensu_url= ENV['SENSU_URL']
    begin
      sensu_checks= JSON.parse(HTTParty.get("#{sensu_url}/checks").to_json)
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end
    checks =[]
    sensu_checks.each do |check|
      # make each event its own individual hash so we can access later
      checks_hash = Hash.new

      #grab necessary attrs
      check_attrs=['name', 'interval', 'timeout', 'standalone', 'subscribers',
        'handlers', 'command', 'type']
      check_attrs.each do |attr|
        checks_hash["#{attr}"] = check["#{attr}"]
      end

      checks << checks_hash
    end

    checks
  end

  def self.get_stashes
    sensu_url= ENV['SENSU_URL']
    begin
      sensu_stashes= JSON.parse(HTTParty.get("#{sensu_url}/stashes").to_json)
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end

    stashes =[]
    sensu_stashes.each do |stash|
      # make each event its own individual hash so we can access later
      stashes_hash = Hash.new

      #grab necessary attrs
      stashes_hash[:path] = stash["path"].to_s
      stashes_hash[:timeout] = stash["content"]["timestamp"].to_s
      stashes_hash[:expire] = stash["content"]["expire"].to_s
      stashes_hash[:reason] = stash["content"]["reason"].to_s
      stashes_hash[:full_content] = stash["content"].to_s

      stashes << stashes_hash
    end

    stashes
  end



  def self.update_clients

    # Purpose of this function: map sensu data onto the Node table

    begin
      sensu_client_data=SensuInfo.get_clients
    rescue
      return false
    end

    sensu_client_data.each do |client|
      node_data = Node.find_or_initialize_by(iso_client_ip: client[:address])

      node_data.update_attributes(
        iso_client_ip: client[:address],
        sensu_client_name: client[:name].to_s,
        sensu_client_address: client[:address].to_s,
        sensu_client_subscriptions: client[:subscriptions].to_s,
        sensu_timestamp: client[:timestamp]
      )

      node_data.save

    end

    return nil #success

  end

  def self.update_checks
    # clear all existing alerts. Sensu is the source of truth
    delete_result = SensuCheck.delete_all

    begin
      sensu_check_data=SensuInfo.get_checks
    rescue
      return false
    end


    # We need to know all the possible subscribers
    # We also need a hash of all the checks to create sensu_checks records later
    subs=Array.new
    checks_hash=Hash.new
    sensu_check_data.each do |check|
      unless check["subscribers"].nil?
        check["subscribers"].each do |s|
          checks_hash["#{check["name"]}"] = {
            :name => check["name"],
            :interval => check["interval"],
            :standalone => check["standalone"],
            :timeout => check["timeout"],
            :handlers => check["handlers"],
            :command => check["command"],
            :check_type => check["type"],
            :subscribers => check["subscribers"]
          }
          subs << s.to_s.gsub(/[^0-9a-z,]/i, '')
        end
      end
    end
    subs = subs.uniq

    # For each check subscriber, search the DB for Nodes with a matching
    # subscription and them create the sensu_check associated record
    subs.each do |s|
      #puts "s: #{s.to_s}"
      @node = Node.all.where('sensu_client_subscriptions LIKE ?', "%#{s}%").to_a
      @node.each do |n|
        #puts n.id
        checks_hash.each_pair do |name, attrs|
          if attrs[:subscribers].include?(s) && attrs[:standalone] != true
            n.sensu_checks.create(
              name: attrs[:name],
              interval: attrs[:interval],
              standalone: attrs[:standalone],
              timeout: attrs[:timeout],
              handlers: attrs[:handlers].to_s,
              command: attrs[:command],
              check_type: attrs[:check_type],
              subscribers: attrs[:subscribers].to_s
            )
          else
            #puts "#{attrs[:subscribers]} = #{s}"
          end
        end
      end
    end
    return nil #success

  end

  def self.update_events
    # clear all existing alerts. Sensu is the source of truth
    delete_result = SensuEvent.delete_all

    # get fresh event info from Sensu itself
    sensu_event_data=SensuInfo.get_events

    # update the iso sensu_events table
    #
    # 'output', 'status', 'issued', 'handlers', 'flapping', 'occurrences',
    # 'client', 'check', \
    # 'id', 'status_name', 'url', 'client_silence_path', 'silence_path',
    # 'client_silenced'
    #
    # it seems that 'client' and 'check' are both Hashes:
    #
    # check"=>"{\"type\"=>\"status\", \"command\"=>\"...\",
    #  \"handlers\"=>[\"hipchat_staging\"],
    #  \"subscribers\"=>[\"datacenter_server\"], \"standalone\"=>false,
    #  \"timeout\"=>90, \"interval\"=>3600,
    #  \"name\"=>\"dbslave_staging_ELB_Checksums\", \"issued\"=>1427400216,
    #  \"executed\"=>1427400216, \"duration\"=>0.315,
    #  \"output\"=>\"...", \"status\"=>1,
    #  \"history\"=>[\"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\",
    #  \"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\", \"1\",
    #  \"1\", \"1\", \"1\"], \"total_state_change\"=>0}

    sensu_event_data.each do |event|
      client_string=event['client']
      client_hash = JSON.parse(client_string.gsub('=>', ':'))
      check_string=event['check']
      check_hash = JSON.parse(check_string.gsub('=>', ':'))
      #puts "DEBUG: " , client_hash.keys, "DEBUG2: ", check_hash.keys
      @node = Node.find_by(sensu_client_name: client_hash['name'])

      unless @node.nil?
        @node.sensu_events.create(
          #date
          output: check_hash['output'],
          status: check_hash['status'],
          handlers: check_hash['handlers'].to_s,
          occurrences: event['occurrences'],
          client: client_hash['name'],
          check: check_hash['name'],
          event_id: event['id'],
          status_name: event['status_name'],
          url: event['url'],
          client_silence_path: event['client_silence_path'],
          silence_path: event['silence_path'],
          client_silenced: event['client_silenced']
        )
        @node.save
      else
        puts "INFO: no node found in ISO db for #{event['client']}"
      end
    end
    return nil #success
  end

  def self.update_stashes
    # clear all existing alerts. Sensu is the source of truth
    delete_result = SensuStash.delete_all

    # get fresh event info from Sensu itself
    sensu_stash_data=SensuInfo.get_stashes

    # update the iso sensu_stashes table
    # API returns: 'path', 'timestamp', 'expire', 'reason', 'full_content'
    # ISO DB :     path, stash_timestamp, expire, reason, full_content,
    # silence_path, client_silence_path

    sensu_stash_data.each do |stash|
      client = "" # to search nodes table

      # sensu returns /silence at beginning of stash path
      if stash[:path].include? 'silence'
        stash[:path]=stash[:path].gsub('silence/','')
      end

      # we need to search on node/client in case of a check-stash
      # vs a client-stash
      if stash[:path].include? '/'
        s = stash[:path].split('/')
        client = s[0]
      else
        client = stash[:path]
      end

      # create stashes via the node-stash association
      @node = Node.find_by(sensu_client_name: client)
      unless @node.nil?

        @node.sensu_stashes.create(
          path:                 stash[:path],
          stash_timestamp:      stash[:timestamp],
          expire:               stash[:expire],
          reason:               stash[:reason],
          full_content:         stash[:full_content],
          silence_path:         stash[:silence_path],
          client_silence_path:  stash[:client_silence_path]
        )
        @node.save
      else
        # this will happen if sensu isn't cleaned up when ec2 nodes are deleted
        puts "INFO: #{client} not found in the ISO DB"
      end
    end
    return nil #success
  end

  def self.find_orphans(instances)
    # Fine nodes in the Nodes table which are no longer in ec2
    # These will still have a registered client on the Sensu server.
    # We want to purge these from Sensu

    #get iso database nodes
    iso_nodes = Nodes.all
    nodes = Array.new

    iso_nodes.each do | i|
      nodes << i[:iso_client_ip]
    end

    orphaned_sensu_clients= Array.new
    orphaned_sensu_clients= instances - nodes

    orphaned_sensu_clients.reject! { |c| c.empty?}

    if orphaned_sensu_clients.nil?
      puts "  Found orphaned_sensu_clients: #{orphaned_sensu_clients}"
      return false
    else
      puts "  None found."
      return nil
    end

  end
end
