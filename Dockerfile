FROM ruby:2.5.0-alpine

# Pg
RUN apk --update --upgrade add postgresql-dev git build-base

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

