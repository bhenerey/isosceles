require 'sinatra/base'

class Isosceles < Sinatra::Base

  ### NEW RELIC
  put '/api/newrelic/servers' do
    puts "begin newrelic server data update"
    NewRelicInfo.update_servers
    status 202
  end
end
