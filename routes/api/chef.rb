require 'sinatra/base'

class Isosceles < Sinatra::Base

  put '/api/chef/nodes' do
    puts "begin chef node data update"
    ChefInfo.update_nodes
    status 202
  end

end
