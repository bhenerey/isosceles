ENV['RACK_ENV'] = 'test'


require_relative '../isosceles.rb'
require 'rspec'
require 'rack/test'

include Rack::Test::Methods

def app
  Isosceles
end

# describe SensuInfo do
#   #METHODS
#   describe '.get_clients' do
#     it 'should get clients' do
#       q=SensuInfo.get_clients
#       q.should_not be_nil
#     end
#   end
#   describe '.get_checks' do
#     it 'should get checks' do
#       q=SensuInfo.get_checks
#       q.should_not be_nil
#     end
#   end
#   describe '.get_events' do
#     it 'should get events' do
#       q=SensuInfo.get_events
#       q.should_not be_nil
#     end
#   end
#   describe '.get_stashes' do
#     it 'should get stashes' do
#       q=SensuInfo.get_stashes
#       q.should_not be_nil
#     end
#   end
#   describe '.update_clients' do
#     it 'should updated the DB with all sensu info' do
#       q=SensuInfo.update_clients
#       puts q
#       q.should be_nil
#     end
#   end
# end

#CONTROLLERS

describe 'GET /api/sensu/events' do
  it "updates the db with all sensu data " do
    get "/api/sensu/events"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end
describe 'GET /api/sensu/checks' do
  it "updates the db with all sensu data " do
    get "/api/sensu/checks"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end
describe 'GET /api/sensu/stashes' do
  it "updates the db with all sensu data " do
    get "/api/sensu/stashes"
    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to eq('application/json')
  end
end
describe 'PUT /api/sensu/checks' do
  it "updates the db with sensu check data " do
    put "/api/sensu/checks"
    expect(last_response.status).to eq(202)
  end
end

describe 'PUT /api/sensu/clients' do
  it "updates the db with sensu client data " do
    put "/api/sensu/clients"
    expect(last_response.status).to eq(202)
  end
end

describe 'PUT /api/sensu/events' do
  it "updates the db with sensu event data " do
    put "/api/sensu/events"
    expect(last_response.status).to eq(202)
  end
end

describe 'PUT /api/sensu/stashes' do
  it "updates the db with sensu stash data " do
    put "/api/sensu/stashes"
    expect(last_response.status).to eq(202)
  end
end

describe 'PUT /api/sensu' do
  it "updates the db with all sensu data " do
    put "/api/sensu"
    expect(last_response.status).to eq(202)
  end
end
