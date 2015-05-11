require 'sinatra/base'
require 'json'
require 'pp'

class ChefSoloInfo
  def self.get_apps
    environment_list = Array.new
    chef_apps_path=File.expand_path(ENV['CHEF_NODE_PATH'])
    Dir.chdir(chef_apps_path)
    self.get_environments.each do |environment|
      environment_hash = Hash.new
      environment_hash[:environment] = environment
      environment_hash[:apps] = Array.new
      Dir.glob("#{environment}/*.{json}").each do |app|
        environment_hash[:apps] << app.split('/')[1].split('.')[0]
      end
      environment_list << environment_hash
    end
    environment_list
  end

  def self.get_environments
    chef_node_path=File.expand_path(ENV['CHEF_NODE_PATH'])
    environments = Dir.entries(chef_node_path).reject{ |d| d.start_with? '.' }
  end

  def self.get_node_list
    chef_node_path=File.expand_path(ENV['CHEF_NODE_PATH'])
    chef_environments=['staging','production']

    chef_apps_data=Hash.new

    #Get list of apps files
    apps_files=[]
    Dir.chdir(chef_apps_path)
    chef_environments.each do |chef_env|
      Dir.glob("#{chef_env}/*.{json}").each do |apps_file|
        apps_files << apps_file
      end
    end

    #Load apps data from files
    chef_apps_data=load_apps_data(apps_files)

    return chef_apps_data

  end

  def self.load_apps_data( apps_files )
    apps_data=Hash.new
    apps_files.each do |filename|
      apps_data[filename] = JSON.parse( IO.read(filename) )
    end

    return apps_data
  end

  def self.get_nodes(chef_env, chef_apps)

    nodes=Array.new

    results = Node.where(:chef_env => chef_env, :chef_apps => chef_apps, :ec2_state => 'running')
    results.each do |node|
      nodes << node
    end

    return nodes

  end

  def self.get_bootstrap

    nodes=Array.new

    results = Node.where(:chef_bootstrapped => "false", :ec2_state => 'running')
    results.each do |node|
      nodes << node
    end

    return nodes

  end

  def self.put_knife_data(data)

    #send event to graphite; different method

    @node = Node.find_by(ec2_private_ip: data["ec2_private_ip"])
    @node.events.create(event_date: Time.now, event_message: data["chef_last_line"])
    @node.save

    return nil

  end

end
