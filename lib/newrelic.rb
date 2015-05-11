class NewRelicInfo

  def self.get_servers

    new_relic_url= ENV['NEW_RELIC_URL']
    new_relic_api_key = ENV['NEW_RELIC_API_KEY']

    begin
      nr_servers = JSON.parse(HTTParty.get("#{new_relic_url}/servers.json",
      :headers => { "X-Api-Key" => new_relic_api_key}).to_json )

    rescue
      puts "Could not connect to New Relic at #{new_relic_url}"
      return nil
    end

    server_list =[]

    nr_servers['servers'].each do |s|
      # make each instance its own individual hash so we can access later


      server_hash = Hash.new

      server_hash[:id]               = s['id']
      server_hash[:name]             = s['name']
      server_hash[:host]             = s['host']
      server_hash[:health_status]    = s['health_status']
      server_hash[:reporting]        = s['reporting']
      server_hash[:last_reported_at] = s['last_reported_at']

      if s['host'].start_with?('ip-')
        server_hash[:nr_ipaddress] = s['host'].gsub("ip-", "").gsub("-",".")
      else
        server_hash[:nr_ipaddress] = nil
      end

      server_list << server_hash
    end

    server_list
  end

  def self.update_servers

    # Purpose of this function: map sensu data onto the Node table

    begin
      new_relic_server_data=NewRelicInfo.get_servers
    rescue
      return false
    end

    ### This code obviously repeats itself a fair bit.

    new_relic_server_data.each do |server|
      if server[:nr_ipaddress].nil?

        # IP address is the best match, but NewRelic doesn't return that value
        # Sometimes the names can be converted to an IP, but if not then
        # try to match on sensu_client_name, ec2_name, chef_name, xen name

        search=server[:host].to_s
        node_data = Node.where("ec2_name LIKE ? OR sensu_client_name LIKE ? OR
            chef_name LIKE ? OR xen_name LIKE ?", "%#{search}%","%#{search}%",
            "%#{search}%","%#{search}%")
        if node_data[0].nil?

          # There's no match
          # CREATE A NEW NODE HERE

          # node_data = Node.find_or_initialize_by(newrelic_host: server[:host])
          #
          # node_data.update_attributes(
          #   newrelic_id: server[:id].to_i,
          #   iso_client_ip: server[:nr_ipaddress].to_s,
          #   newrelic_name: server[:name].to_s,
          #   newrelic_host: server[:host].to_s,
          #   newrelic_reporting: server[:reporting].to_s,
          #   newrelic_health_status: server[:health_status].to_s,
          #   newrelic_last_reported_at: server[:last_reported_at].to_s
          # )
          #
          # node_data.save
        else
          #UPDATE THE NODE HERE
          node_data[0].update_attributes(
           newrelic_id: server[:id].to_i,
           iso_client_ip: server[:nr_ipaddress].to_s,
           newrelic_name: server[:name].to_s,
           newrelic_host: server[:host].to_s,
           newrelic_reporting: server[:reporting].to_s,
           newrelic_health_status: server[:health_status].to_s,
           newrelic_last_reported_at: server[:last_reported_at].to_s
         )

         node_data[0].save

        end


      else
        # The newrelic name is translatable to an IP address we know of
        node_data = Node.find_by(iso_client_ip: server[:nr_ipaddress])
        if node_data.nil?
          # we don't want NewRelic creating nodes, only updating
          # could put some logic here to capture orphans
        else
          node_data.update_attributes(
            newrelic_id: server[:id].to_i,
            iso_client_ip: server[:nr_ipaddress].to_s,
            newrelic_name: server[:name].to_s,
            newrelic_host: server[:host].to_s,
            newrelic_reporting: server[:reporting].to_s,
            newrelic_health_status: server[:health_status].to_s,
            newrelic_last_reported_at: server[:last_reported_at].to_s
          )
          node_data.save
        end
      end
    end

    return nil #success

  end




end
