task :update_all do
  puts 'update from aws'
  AwsInfo.update_nodes
  puts 'update all sensu'
  SensuInfo.update_clients

  #These 3 tables need to be purged before updating
  SensuEvent.delete_all
  SensuInfo.update_events

  SensuCheck.delete_all
  SensuInfo.update_checks

  SensuStash.delete_all
  SensuInfo.update_stashes
end
