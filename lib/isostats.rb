require 'sinatra/base'
require 'json'

class IsoStats
  def self.get_info
    # Total Nodes
    # Nodes with no Sensu
    # Nodes with no Chef
    # Nodes with errors

    iso_stats = Hash.new

    iso_stats[:total_nodes] = Nodes.count
    iso_stats[:chef_nodes] = Nodes.count(:chef_last_ohai)
    iso_stats[:sensu_nodes] = Nodes.count(:sensu_client_name)
    iso_stats[:error_nodes] = Nodes.all.where.not('sensu_events_count' => 0).count
    iso_stats[:ec2_nodes] = Nodes.where.not(:ec2_id => nil).count
    iso_stats[:xen_nodes] = Nodes.where.not(:xen_name => nil).count
    iso_stats[:health_chef_nodes] = "Unknown" #chef ohai & known ipaddress
    iso_stats[:health_sensu_nodes] = "Unknown" #sensu timestamp
    iso_stats[:new_relic_dead] = Nodes.where(:newrelic_reporting => false).count
    return iso_stats.to_json
  end

  def self.chef_healthy

    chef_nodes = Nodes.all.where.not(:chef_last_ohai => nil )
    chef_nodes.each do |n|
      last_ohai=time_since_in_mins(n[:chef_last_ohai])
      case healthy
      when 0..60
        puts "green"
      when 61..1440
        puts "yellow"
      else
        puts "red"
      end
    end

  end
end
