require 'sinatra/base'

class Isosceles < Sinatra::Base

  #### All of these routes are just intended for debugging. The front-end
  # is being developed separately as a javascript app
  get '/' do
    redirect "/nodes", 302
  end

  get '/nodes' do
    @nodes = Nodes.where.not(ec2_state: "terminated").order("aws_tag_environment, aws_tag_apps, sensu_events_count")
    # @nodes = Nodes.where.not(ec2_state: "terminated").order("aws_tag_environment, aws_tag_apps, sensu_events_count")
    erb :nodes, :layout => :base do
      erb :nodes
    end
  end

  get '/nodes/:id' do
    @node = Node.where(id: params[:id])
    @node.each do |n|
      @events = Event.where(node_id: n.id).order("created_at DESC")
      @sensu_events = SensuEvent.where(node_id: n.id).order("created_at DESC")
      @sensu_stashes = SensuStash.where(node_id: n.id).order("created_at DESC")
      @sensu_checks = SensuCheck.where(node_id: n.id).order("created_at DESC")
      puts @sensu_checks
    end
    erb :"nodes/index", :layout => :base do
        erb :"nodes/index"
    end
  end

  get '/sensu/events' do
    @nodes = Node.where("sensu_events_count > ?", 0).order("chef_env ASC, sensu_client_name ASC");
    @events = SensuEvent.all
    @stashes = SensuStash.all
    erb :"sensu/events", :layout => :base do
        erb :"sensu/events"
    end
  end

  get '/sensu/stashes' do
    @nodes = Node.where("sensu_stashes_count > ?", 0).order("chef_env ASC, sensu_client_name ASC");
    @events = SensuEvent.all
    @stashes = SensuStash.all
    erb :"sensu/stashes", :layout => :base do
        erb :"sensu/stashes"
    end

  end

end
