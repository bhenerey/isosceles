require 'sinatra/base'

class Isosceles < Sinatra::Base

  ### AWS
  put '/api/aws' do
    response=AwsInfo.update_nodes
    if response.nil?
      status 202
    else
      status 500
    end
  end

end
