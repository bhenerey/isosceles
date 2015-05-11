require 'sinatra/base'
require 'fog'
require 'json'
require 'logger'


class AwsInfo
  #method to return array of hashes which contain nodes grouped by tag
  def self.get_apps

    # this is the array we'll be returning full of node data
    app_array = Array.new

    #grab all apps tags on AWS and loop through them
    apps = Node.select(:chef_apps).where(:ec2_state => 'running').distinct.order(chef_apps: :asc)

    apps.each do |app|
      puts app.inspect
      app_hash = Hash.new
      node_data = Node.where(chef_apps: app.chef_apps)
      puts node_data.inspect
      app_hash[:name] = app.chef_apps
      app_hash[:nodes] = node_data
      app_array << app_hash
    end

    #return tag array
    app_array
  end

  def self.get_instances
    server_list =[]

    begin

      # We need to get instances from multiple regions
      region_list=['us-east-1', "us-west-2", "us-west-1"]
      region_list.each do |region|

        puts "Fetching instance data from #{region}"
        # Set up a connection
        connection = Fog::Compute.new({
          :provider => 'AWS',
          :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
          :region => region
        })

        connection.servers.all.each do |server|
          # make each instance its own individual hash so we can access later
          server_hash = Hash.new

          #grab necessary attrs
          server_hash[:hash]        = server
          server_hash[:name]        = server.tags["Name"]
          server_hash[:environment] = server.tags["environment"] ||= "no tag yet"
          server_hash[:bootstrapped] = server.tags["bootstrapped"]
          server_hash[:apps]        = server.tags["apps"] ||= "no apps yet"
          server_hash[:id]          = server.id.to_s
          server_hash[:private_ip]  = server.private_ip_address.to_s
          server_hash[:flavor]      = server.flavor_id.to_s
          server_hash[:az]          = server.availability_zone
          server_hash[:ec2_state]       = server.state

          # append our hash of server attrs and return the server_list
          server_list << server_hash
        end

      end

    rescue
      puts "unable to connect to AWS"
      return nil
    end

    server_list
  end


  def self.update_nodes

    ec2_server_data=AwsInfo.get_instances
    if ec2_server_data.nil?
      return false
    else

      ec2_server_data.each do |server|
        node_data = Node.find_or_initialize_by(iso_client_ip: server[:private_ip])

        node_data.update_attributes(
          ec2_name: server[:name],
          ec2_id: server[:id],
          aws_tag_environment: server[:environment],
          aws_tag_apps: server[:apps],
          chef_bootstrapped: server[:bootstrapped],
          ec2_state: server[:ec2_state],
          ec2_private_ip: server[:private_ip],
          ec2_availability_zone: server[:az],
          iso_client_ip: server[:private_ip]
        )
        node_data.save

      end
      return nil
    end

  end

end
