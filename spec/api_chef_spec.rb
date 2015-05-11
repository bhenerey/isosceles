ENV['RACK_ENV'] = 'test'


require_relative '../isosceles.rb'
require 'rspec'
require 'rack/test'

include Rack::Test::Methods

def app
  Isosceles
end

describe 'PUT /api/chef/nodes' do
  it "should respond with a 202" do
    put "/api/chef/nodes"
    expect(last_response.status).to eq(202)
  end
end
