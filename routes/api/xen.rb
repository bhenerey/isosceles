require 'sinatra/base'

class Isosceles < Sinatra::Base

  ### XenServer
  put '/api/xen' do
    response=XenServerInfo.update_vms
    if response.nil?
      status 202
    else
      status 500
    end
  end

end
