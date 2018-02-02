FROM ruby:2.5.0-alpine as bundler

# Pg
RUN apk --update --upgrade add postgresql-dev git build-base

ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

# Bundle
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem update bundler && bundle install --jobs 4

# Stage 2
FROM ruby:2.5.0-alpine
RUN apk --update --upgrade add postgresql-dev
EXPOSE 80

ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

# Copy the rest of source
COPY . /app
COPY --from=bundler /usr/local/bundle /usr/local/bundle
RUN rm -rf /usr/local/bundle/cache
