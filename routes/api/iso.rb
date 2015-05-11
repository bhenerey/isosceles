require 'sinatra/base'

class Isosceles < Sinatra::Base

  get '/api/nodes' do
    nodes = Nodes.order("created_at DESC")
    content_type :json
    return nodes.to_json
  end

  get '/api/nodes/:id' do
    @node = Node.where(id: params[:id])

    node_hash=Hash.new
    node_hash[:node] = @node

    @node.each do |n|
      node_hash[:events] = Event.where(node_id: n.id).order("created_at DESC")
      node_hash[:sensu_events] = SensuEvent.where(node_id: n.id).order("created_at DESC")
      node_hash[:sensu_stashes] = SensuStash.where(node_id: n.id).order("created_at DESC")
      node_hash[:sensu_checks] = SensuCheck.where(node_id: n.id).order("created_at DESC")
    end

    content_type :json
    return node_hash.to_json
  end

  get '/api/health' do
    content_type :json
    return "OK".to_json
  end

  get '/api/stats' do
    content_type :json
    response=IsoStats.get_info
    return response 
  end

end
