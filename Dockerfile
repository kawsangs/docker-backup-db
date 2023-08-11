FROM ruby:3.1.2

LABEL maintainer="Kakada CHHEANG <kakada@kawsang.com>"

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler:2.4.18 && \
  bundle config set deployment 'true' && \
  bundle install --jobs 10

ADD . /app
