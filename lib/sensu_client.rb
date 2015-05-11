require 'sinatra/base'
require 'fog'
require 'json'
require 'httparty'


class SensuClient
  #DELETE CLIENT
  def self.del_client(id, client)
    sensu_url= ENV['SENSU_URL']
    begin
      status= HTTParty.delete("#{sensu_url}/clients/#{client}")
      puts status.code
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end
    result = SensuEvent.where(node_id: id).delete_all
    result = SensuStash.where(node_id: id).delete_all
  end

  #RESOLVE EVENT
  def self.del_event(id, client, check)
    sensu_url= ENV['SENSU_URL']
    begin
      status= HTTParty.delete("#{sensu_url}/events/#{client}/#{check}")
      puts status.code
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end
    result = SensuEvent.where(id: id).delete_all
  end

  #DELETE STASH
  def self.del_stash(id, stash_path)
    sensu_url= ENV['SENSU_URL']
    begin
      status= HTTParty.delete("#{sensu_url}/stashes/#{stash_path}")
      puts status.code
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end
    puts "Deleting SensuStasu ID: #{id}"
    result = SensuStash.where(id: id).delete_all

    return nil
  end

  class ServiceWrapper
    include HTTParty

    query_string_normalizer proc { |query|
      query.map do |key, value|
        value.map {|v| "#{key}=#{v}"}
      end.join('&')
    }
  end

  #POST STASH
  def self.post_stash(id, client, check)
    sensu_url= ENV['SENSU_URL']
    begin
      status= HTTParty.post("#{sensu_url}/stashes/silence/#{client}/#{check}",
      :body => {:path => "silence/#{client}/#{check}"}.to_json,
      :options => { :headers => { 'ContentType' => 'application/json' } })

      puts status.code
    rescue
      puts "Could not connect to Sensu at #{ENV['SENSU_URL']}"
      return nil
    end
  end

end
