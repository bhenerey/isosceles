require 'sinatra/base'

class Isosceles < Sinatra::Base

  ### SENSU
  get '/api/sensu/events' do
    #return list of sensu events from the ISO db
    events = SensuEvent.order("created_at DESC")
    content_type :json
    return events.to_json
  end

  get '/api/sensu/stashes' do
    #return list of sensu stashes from the ISO db
    stashes = SensuStash.order("created_at DESC")
    content_type :json
    return stashes.to_json
  end

  get '/api/sensu/checks' do
    #return list of sensu stashes from the ISO db
    checks = SensuCheck.order("created_at DESC")
    content_type :json
    return checks.to_json
  end

  ### Update sensu data from the external Sensu API
  put '/api/sensu' do
    puts "begin sensu data update"
    SensuInfo.update_clients
    SensuInfo.update_checks
    SensuInfo.update_events
    SensuInfo.update_stashes
    status 202
  end

  put '/api/sensu/clients' do
    puts "begin sensu client data update"
    SensuInfo.update_clients
    status 202
  end

  put '/api/sensu/checks' do
    puts "begin sensu check data update"
    SensuInfo.update_checks
    status 202
  end

  put '/api/sensu/events' do
    puts "begin sensu event data update"
    SensuInfo.update_events
    status 202
  end

  put '/api/sensu/stashes' do
    puts "begin sensu stash data update"
    SensuInfo.update_stashes
    status 202
  end

  #SENSU CLIENT UNSAFE ACTIONS

  #STASHES
  post '/api/sensu/stashes' do
    if params[:sensu_method] == "delete"
      puts "Deleting Sensu Stash: #{params[:stashpath]}"
      SensuClient.del_stash(params[:id],params[:stashpath])
      SensuInfo.update_stashes
    elsif params[:sensu_method] == "post"
      puts "Posting Sensu Stash: #{params[:client]}/#{params[:check]}"
      SensuClient.post_stash(params[:id],params[:client],params[:check])
      SensuInfo.update_stashes
    else
      puts "not found", params
      status 404
    end
    redirect to(request.referrer)
    status 202
  end

  #EVENTS
  post '/api/sensu/events' do
    if params[:sensu_method] == "delete"
      puts "Resolving(Deleting) Sensu Event: #{params[:client]}/#{params[:check]}"
      SensuClient.del_event(params[:id],params[:client],params[:check])
      SensuInfo.update_events
    #elsif params[:sensu_method] == "post"
    #  SensuClient.post_event(params[:id],params[:client],params[:check])
    else
      puts "not found", params
      status 404
    end
    redirect to(request.referrer)
    status 202
  end

  #CLIENTS
  post '/api/sensu/clients' do
    if params[:sensu_method] == "delete"
      puts "Deleting Sensu Client: #{params[:client]}"
      SensuClient.del_client(params[:id],params[:client])
      SensuInfo.update_clients
    #elsif params[:sensu_method] == "post"
    #  SensuClient.post_client(params[:id],params[:client])
    else
      puts "not found", params
      status 404
    end
    redirect to(request.referrer)
    status 202
  end

end
