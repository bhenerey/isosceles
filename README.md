# What is Isosceles?

At a high-level, Isosceles is a light-weight application aimed at providing a single **"source of truth"** for Web Operations Infrastructure, and making that infrastructure data **actionable** from a centralized place.

## Contents

1. [Background](#background)
2. [Getting Started](#gettingStarted)
3. [API](#api)

## <a name="background">Background</a>

### Collecting the data

Initially, Isosceles is developed to pull data from multiple external APIs that common in "devops" environments. These 3rd-party services include **AWS**, **Chef**, **Sensu** and **New Relic**, which each return different meta-data pertaining to what Isosceles calls a "Node" object. Mapping together this diverse data into a single database entry is what allows us to create unified views of our Nodes, and also empowers us to keep the 3rd party services in sync with each other when we perform actions on our Nodes.

### What is a Node object?

Each system we use has a different name for what we're calling a Node object:

| Service   | Node Name | Type of Node
|-----------|----------|-----------------------
| AWS/EC2   | instance | virtual machine(vm)
| Chef      | node     | vm or physical server
| Sensu     | client   | vm or physical server
| New Relic | server   | vm or physical server

When we map together the data, we treat instance/node/client/server as the same thing. The reason I named the Isosceles entity a Node is because not everything is a server, nor a vm, nor an instance, nor a client. "Node" is the only word in our lexicon that is generic enough to cover all of our infrastructure components.

### Mapping the data together

Each 3rd party service returns data in it's own structure. I'm using "ip address" as a unique identifier when trying to map the meta-data togeher.

*Warning 1:* IP addresses might not be unique in your environment. It works for us, for now.

*Warning 2:* There are scenarios where Chef doesn't know any IP address (failed bootstrapping?), and New Relic does not report the IP address. You'll need to read the code for how that is handled.

### Keeping 3rd party services synchronized

Because cloud infrastructure is ephemeral, and because our "tool-chain" approach leverages multiple systems which are not integrated, it's easy for orphaned data to remain in our systems that we don't want.

For example, if you terminate an ec2 instance, the Sensu client won't automatically be deleted. Chef and New Relic will also still report on this
"Node", but we should write janitorial tasks to to clean this up.


### Actionable data

Besides just deleting a Node, there are other actions we could perform:

- "Cook" a server - trigger a chef-client run on a server or servers
- Sensu functionality:
  - Stash a client
  - Stash an event
  - Resove an event

### Future integrations

#### Pagerduty, StatusPage

As Isosceles because used on a regular basis, displaying information such as active Pagerduty incidents, or displaying StatusPage status in the UI would be useful.

- show who's on call
- acknowledge events, with integrations to HipChat and/or Logstash
- show current StatusPage status

#### Jenkins

Jenkins is a likely mechanism for enabling "Cooking" of servers, as well as triggering deployments. For now, I'd rather Isosceles just be the glue between our different tools, but not be responsible for doing the actual work.

## <a name="gettingStarted">Getting Started</a>

### Dependencies

#### Docker

We use Docker when developing locally. First, this is so that we can have a
local Postgres database. Second, so that we can package Isosceles into an image

- boot2docker https://docs.docker.com/installation/mac/
- fig http://www.fig.sh/

Once you have both of those installed, run:

	fig up

Postgresl will now be started in a container you can access.


### Env Vars

```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export SENSU_URL=http://sensu.prod.opinionlab.com:4567
export NEW_RELIC_URL=https://api.newrelic.com/v2/
export NEW_RELIC_API_KEY="<In LastPass>"
export POSTGRES_USERNAME="postgres"
export POSTGRES_PASSWORD=""
export POSTGRES_URL="192.168.59.103" #boot2docker default IP
export POSTGRES_PORT="5432"
export CHEF_CLIENT_NAME="isosceles"
export CHEF_CLIENT_KEY="isosceles.pem"
export CHEF_VALIDATOR_NAME="chef-validator"
export CHEF_VALIDATION_KEY="chef-validator.pem"
export CHEF_URL="https://chef.opinionlab.com"
```
CHEF - you need to create an isosceles client with appropriate permissions to interact with the API. As of this writing, read-only would be sufficient.


### Bundler

You need to have ruby >2.0 installed, and bundler. Check the Dockerfile for how this is done and adapt it to your Mac if need be:

	bundle install

### Database initial schema setup

	rake db:create
	rake db:migrate

run the app with shotgun:

	shotgun --server=thin --port=9292 config.ru

or build the docker container and run it:

	docker build .
	docker run   -p 8080:8080 <image_id>

Initial data load: (need to automate this)

```
curl  -XPUT http://localhost:9292/api/aws -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/clients -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/events -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/checks -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/stashes -H 'Content-Length: 0'
```

## <a name="api">API</a>

*Note, sometimes my examples show that I'm piping the json results through [jq](http://stedolan.github.io/jq/)*

### AWS

Update the db with data from us-east-1, us-west-1, us-west-2

> curl  -XPUT http://localhost:9292/api/aws -H 'Content-Length: 0'

### Sensu

Updates sensu client, event, stash, and checks data all at once

> curl  -XPUT http://localhost:9292/api/sensu -H 'Content-Length: 0'

Update only the specific sensu data, such as only sensu event data

```
curl  -XPUT http://localhost:9292/api/sensu/clients -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/events -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/checks -H 'Content-Length: 0'
curl  -XPUT http://localhost:9292/api/sensu/stashes -H 'Content-Length: 0'
```



Stash an event

```
*Need to create an example here*
```

Delete a stash

```
*Need to create an example here*
```

Resolve an event

```
*Need to create an example here*
```

Delete a client

```
*This hasn't been developed yet*
```

### Chef

Update the db with Chef node data

```
curl  -XPUT http://localhost:9292/api/chef/nodes -H 'Content-Length: 0'
```

Delete a Chef node

```
*This hasn't been developed yet*
```


### New Relic

Update the db with NewRelic data

```
curl  -XPUT http://localhost:9292/api/newrelic/servers -H 'Content-Length: 0'
```

### Isosceles

Return all Node data from the Isosceles database

```
curl -XGET http://localhost:9292/api/nodes| jq '.'
```

Return a specific Node's data, including related Sensu data

```
curl -XGET http://localhost:9292/api/nodes/:id| jq '.'
```


Delete a Node across all 3rd party services

```
*This hasn't been developed yet*
```

### Stats

Return some metrics on our Isosceles data

```
curl -XGET http://localhost:9292/api/stats | jq '.'
```
