require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'fog'
require 'json'
require 'logger'
require 'rufus/scheduler'
require_relative 'helpers/init'
require 'active_support/core_ext/string/output_safety'


class Nodes < ActiveRecord::Base
end

class Isosceles < Sinatra::Base
  register Sinatra::CrossOrigin
  enable :cross_origin

  require_relative 'routes/init'
  require_relative 'models/init'
  require_relative 'lib/init'
  helpers Sinatra::Isosceles::Helpers

end
