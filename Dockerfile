FROM ruby:2.4.2

# Pg
RUN apt-get update -qq && apt-get install \
    -y build-essential libpq-dev lsb-release

ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

EXPOSE 80

# Bundle
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem update bundler && bundle install --jobs 4

# Copy the rest of source
COPY . /app

