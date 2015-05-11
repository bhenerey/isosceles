FROM ruby:latest

MAINTAINER Brian Henerey <bhenerey@gmail.com>

# Install dependencies.
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
  libpq-dev libsqlite3-dev

# Copy the Gemfile into place
RUN mkdir /srv/isosceles
ADD Gemfile /srv/isosceles/Gemfile
ADD Gemfile.lock /srv/isosceles/Gemfile.lock

# Setup the non-privileged user
# Never got the app to work under the sinatra user. never could find the gems
#RUN adduser --disabled-password --home=/sinatra --gecos "" sinatra
#RUN chown sinatra /srv/isosceles
#USER sinatra

# Install gem dependencies
WORKDIR /srv/isosceles
RUN bundle install

# Create dirs needed by Unicorn
RUN mkdir tmp
RUN mkdir tmp/sockets
RUN mkdir tmp/pids
RUN mkdir log

# Copy the app into the image.
ADD . /srv/isosceles

CMD bundle exec unicorn -c unicorn.rb
