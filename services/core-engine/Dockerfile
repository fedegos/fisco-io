# Fisco.io - Core Engine
# Rails app for event store and aggregates

FROM ruby:3.2-alpine

RUN apk add --no-cache build-base libpq-dev yaml-dev nodejs tzdata

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
# Instalar todas las gems (incl. test y development) para poder correr rspec y rubocop
RUN bundle install --jobs 4 --retry 3

COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
