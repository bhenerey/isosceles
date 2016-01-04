while x=1 ; do for i in aws sensu; do curl -XPUT http://localhost:9292/api/$i ; done; echo `date`; sleep 60; done
