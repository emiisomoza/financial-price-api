# Price API 💱

![CI](https://github.com/emiisomoza/price-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/ruby-3.4-red)
![Sinatra](https://img.shields.io/badge/sinatra-4.x-blue)
![License](https://img.shields.io/badge/license-MIT-green)

REST API built in **Ruby (Sinatra)** that resolves real-time asset prices across multiple asset types (FX, crypto, stocks) using the **Strategy design pattern**.

This service is part of a larger financial portfolio system:
- 🇯🇦 **[Finance API](https://github.com/emiisomoza/finantial-profile-api)** — Java/Spring Boot: manages users, income, expenses and assets
- 💱 **Price API** (this repo) — Ruby/Sinatra: resolves real-time asset prices
- 🐍 **[Notifier](https://github.com/emiisomoza/notifier)** — Python: consumes a queue and sends monthly summary emails

---

## Design Pattern — Strategy

Each asset type has its own conversion strategy that implements a common interface:
```
BaseConversion
    ├── FxConversion      → open.er-api.com
    ├── CryptoConversion  → CoinGecko API
    └── StockConversion   → Finnhub API
```

Adding a new asset type only requires creating a new strategy class and registering it in `PriceResolver` — no changes to the endpoint or existing code.

---

## Endpoint

### `GET /v1/price`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `assetType` | string | ✅ | `fx`, `crypto`, `stock` |
| `asset` | string | ✅ | e.g. `USD`, `BTC`, `AAPL` |
| `currency` | string | ✅ | Target currency e.g. `AUD`, `USD` |

#### Examples
```bash
# FX — how much is 1 USD in AUD
GET /v1/price?assetType=fx&asset=USD&currency=AUD

# Crypto — how much is 1 BTC in AUD
GET /v1/price?assetType=crypto&asset=BTC&currency=AUD

# Stock — how much is 1 AAPL share in AUD
GET /v1/price?assetType=stock&asset=AAPL&currency=AUD
```

#### Response
```json
{
  "asset": "BTC",
  "currency": "AUD",
  "price": 98234.12,
  "asset_type": "crypto",
  "source": "coingecko.com"
}
```

#### Error responses
```json
// 400 - Missing parameters
{ "error": "Missing required parameters: assetType" }

// 422 - Unsupported asset type
{ "error": "Unsupported asset_type: 'nft'. Valid: fx, crypto, stock" }

// 500 - Internal error
{ "error": "Internal server error", "detail": "..." }
```

---

## Tech Stack

| | |
|---|---|
| Language | Ruby 3.4 |
| Framework | Sinatra |
| HTTP Client | Faraday |
| Testing | RSpec + WebMock + Rack::Test |
| CI | GitHub Actions |

---

## External APIs

| Asset Type | API | Auth |
|---|---|---|
| `fx` | [open.er-api.com](https://open.er-api.com) | None |
| `crypto` | [CoinGecko](https://www.coingecko.com/api) | None |
| `stock` | [Finnhub](https://finnhub.io) | Free API key |

---

## Run locally

### Prerequisites
- Ruby 3.4+
- Bundler

### Setup
```bash
git clone https://github.com/emiisomoza/price-api.git
cd price-api
bundle install
cp .env.example .env
```

Edit `.env` and add your Finnhub API key (free at [finnhub.io](https://finnhub.io)):
```
FINNHUB_API_KEY=your_key_here
PORT=4567
```

### Start the server
```bash
bundle exec puma -p 4567 config.ru
```

> `ruby app.rb` causes a Puma path resolution error when the project is not at its original cloned location. Use `bundle exec puma` instead.

API available at `http://localhost:4567`

---

## Run tests
```bash
# All tests
bundle exec rspec --format documentation

# Unit tests only
bundle exec rspec spec/unit

# Integration tests only
bundle exec rspec spec/integration
```

---

## Project structure
```
price-api/
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions CI
├── price_conversion/
│   ├── base_conversion.rb   # Abstract strategy
│   ├── fx_conversion.rb     # FX strategy
│   ├── crypto_conversion.rb # Crypto strategy
│   └── stock_conversion.rb  # Stock strategy
├── services/
│   └── price_resolver.rb    # Strategy selector
├── spec/
│   ├── spec_helper.rb
│   ├── support/
│   │   └── fixtures.rb
│   ├── unit/
│   │   ├── fx_conversion_spec.rb
│   │   ├── crypto_conversion_spec.rb
│   │   └── stock_conversion_spec.rb
│   └── integration/
│       └── price_endpoint_spec.rb
├── app.rb                   # Sinatra app & routes
├── config.ru                # Rack entry point
├── Gemfile
├── .env.example
└── README.md
```

---

## License

MIT