# Price API 🏷️

REST API built in Ruby (Sinatra) that resolves asset prices across 
multiple asset types using the Strategy pattern.

## Endpoints
GET /v1/price?assetType=fx&asset=USD&currency=AUD

## Stack
- Ruby + Sinatra
- Strategy Pattern
- External APIs: open.er-api.com, CoinGecko, Finnhub

## Run locally
bundle install
cp .env.example .env
ruby app.rb

