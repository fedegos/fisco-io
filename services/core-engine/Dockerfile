# Fisco.io - Core Engine
# Rails app for event store and aggregates

FROM ruby:3.2-alpine

RUN apk add --no-cache build-base libpq-dev nodejs tzdata

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 || true

COPY . .

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
