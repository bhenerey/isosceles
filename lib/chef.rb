require 'sinatra/base'
require 'json'
require 'pp'
require 'rubygems'
require 'chef/rest'
require 'chef/search/query'
require 'date'

class ChefInfo

  def self.get_nodes
    Chef::Config.node_name=               ENV['CHEF_CLIENT_NAME']
    Chef::Config.client_key=              "/etc/chef/#{ENV['CHEF_CLIENT_KEY']}"
    Chef::Config.validation_client_name=  ENV['CHEF_VALIDATOR_NAME']
    Chef::Config.validation_key =         "/etc/chef/#{ENV['CHEF_VALIDATION_KEY']}"
    Chef::Config.chef_server_url =        ENV['CHEF_URL']

    query = Chef::Search::Query.new
    nodes = query.search('node', query = '*:*').first rescue []

    node_list =[]
    nodes.each do |n|
      # make each instance its own individual hash so we can access later
      node_hash = Hash.new
      time_now = Time.now.to_i

      node_hash[:name]              = n.name #rescue 'unknown'
      node_hash[:ipaddress]         = n.ipaddress rescue nil
      node_hash[:chef_environment]  = n.chef_environment
      node_hash[:primary_runlist]   = n.primary_runlist
      node_hash[:uptime]            = n.uptime rescue 'unknown'
      node_hash[:chef_version]      = n.chef_packages.chef.version rescue 'unknown'
      node_hash[:platform]          = "#{n.platform} #{n.platform_version}" rescue "unknown"
      node_hash[:ohai_time]         = n.ohai_time rescue nil

      # append our hash of server attrs and return the server_list

      node_list << node_hash
    end

    node_list
  end

  def self.update_nodes

    # Purpose of this function: map chef data onto the Node table

    begin
      chef_node_data=ChefInfo.get_nodes
    rescue
      return false
    end

    chef_node_data.each do |chef_node|
      if chef_node[:ipaddress].nil?
        puts "chef node with no IP should not get added to the database"
      else
        node_data = Node.find_by(iso_client_ip: chef_node[:ipaddress])

        if node_data.nil?
          # We only want chef to update nodes, not create them.
          # Could put logic here to capture orphans
        else
          node_data.update_attributes(
            chef_name:          chef_node[:name],
            iso_client_ip:      chef_node[:ipaddress].to_s,
            chef_env:           chef_node[:chef_environment].to_s,
            chef_runlist:       chef_node[:primary_runlist].to_s,
            chef_uptime:        chef_node[:uptime].to_s,
            chef_version:       chef_node[:chef_version].to_s,
            chef_platform:      chef_node[:platform].to_s,
            chef_last_ohai:     chef_node[:ohai_time].to_i,
          )

          node_data.save
        end
      end
    end

    return nil #success

  end
end
