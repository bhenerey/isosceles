require 'fog'
require 'pp'
require 'yaml'


class XenServerInfo

  def self.get_vms

    begin
      cnf = YAML::load(File.open('config/xen.yml'))
      puts "KEYS: #{cnf.keys}"
      vm_list=[]
    rescue => ex
      puts "EXCEPTION: #{ex}"
    end
    # We have multiple Xen Servers, so we pull data from each
    cnf.keys.each do |xen|
      xserver=cnf[xen]['xenserver_name']
      begin
        xserver_url = xserver + "_URL"
        xserver_username = xserver + "_USERNAME"
        xserver_password = xserver + "_PASSWORD"

        conn = Fog::Compute.new({
          :provider => cnf["#{xen}"]["provider"],
          :xenserver_url => ENV[xserver_url],
          :xenserver_username => ENV[xserver_username],
          :xenserver_password => ENV[xserver_password],
          :xenserver_defaults => {
            :template => "squeeze-test"
          }
        })
        conn.servers.each do |vm|
          # make each instance its own individual hash so we can access later
          vm_hash = Hash.new

          #grab necessary attrs
          if vm.tools_installed?
            networks=Array.new
            vm.guest_metrics.networks.each do |k,v|
              networks <<  v
            end
            vm_hash[:ipaddress] = networks[-1]
          end
          vm_hash[:name] = vm.name
          vm_hash[:power_state] = vm.power_state
          vm_hash[:last_shutdown_time] = vm.other_config["last_shutdown_time"]

          vm_list << vm_hash
        end
      rescue => ex
        puts ex, "Could not connect to the Xen Server: #{xen}"
      end
    end
    vm_list
  end



  def self.update_vms

    # Purpose of this function: map xenserver data onto the Node table

    begin
      xen_server_data=XenServerInfo.get_vms
    rescue
      return false
    end

    xen_server_data.each do |vm|
      node_data = Node.find_or_initialize_by(iso_client_ip: vm[:ipaddress])

      node_data.update_attributes(
        iso_client_ip: vm[:ipaddress],
        xen_name: vm[:name].to_s,
        xen_power_state: vm[:power_state].to_s,
        xen_last_shutdown_time: vm[:last_shutdown_time].to_s
      )

      node_data.save

    end

    return nil #success

  end

end
