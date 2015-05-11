ENV['RACK_ENV'] = 'test'


require_relative '../isosceles.rb'
require 'rspec'
require 'rack/test'

include Rack::Test::Methods

def app
  Isosceles
end

describe 'GET /api/stats' do
  it "gets stats on isosceles data" do
    get "/api/stats"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end

describe 'GET /api/health' do
  it "gets health of isosceles service" do
    get "/api/health"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end

describe 'GET /api/nodes' do
  it "gets all Node data" do
    get "/api/nodes"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end

describe 'GET /api/nodes/:id' do
  it "gets individual node data" do
    get "/api/nodes/1"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end
