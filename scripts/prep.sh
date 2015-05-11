#!/bin/bash
#export SENSU_URL='http://<URL>:4567'
#export ISOSCELES_URL='http://localhost:9292'

while true; do
  curl  -XPUT http://localhost:9292/api/aws -H 'Content-Length: 0'
  curl  -XPUT http://localhost:9292/api/sensu/clients -H 'Content-Length: 0'
  curl  -XPUT http://localhost:9292/api/sensu/events -H 'Content-Length: 0'
  curl  -XPUT http://localhost:9292/api/sensu/checks -H 'Content-Length: 0'
  curl  -XPUT http://localhost:9292/api/sensu/stashes -H 'Content-Length: 0'
  sleep 60
done
