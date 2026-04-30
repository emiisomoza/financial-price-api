FROM ruby:3.4-alpine
WORKDIR /app
RUN apk add --no-cache build-base
COPY Gemfile Gemfile.lock ./
RUN bundle install --without test
COPY . .
RUN addgroup -S app && adduser -S app -G app
USER app
EXPOSE 4567
CMD ["bundle", "exec", "puma", "-p", "4567", "config.ru"]
