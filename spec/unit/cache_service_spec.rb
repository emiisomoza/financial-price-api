require_relative "../spec_helper"

RSpec.describe Services::CacheService do
  let(:redis_double) { instance_double(Redis) }

  before do
    allow(Config::REDIS_POOL).to receive(:with).and_yield(redis_double)
  end

  describe ".fetch" do
    context "when cache hit" do
      it "returns cached value without calling the block" do
        allow(redis_double).to receive(:get).and_return('{"asset":"USD","price":1.55}')

        called = false
        result = described_class.fetch("price:fx:usd:aud", asset_type: "fx") { called = true }

        expect(called).to be false
        expect(result[:asset]).to eq("USD")
      end
    end

    context "when cache miss" do
      before do
        allow(redis_double).to receive(:get).and_return(nil)
        allow(redis_double).to receive(:setex)
      end

      it "calls the block and returns the result" do
        result = described_class.fetch("price:fx:usd:aud", asset_type: "fx") { { asset: "USD", price: 1.55 } }
        expect(result[:asset]).to eq("USD")
      end

      it "uses 15s TTL for crypto" do
        described_class.fetch("price:crypto:btc:aud", asset_type: "crypto") { { asset: "BTC" } }
        expect(redis_double).to have_received(:setex).with("price:crypto:btc:aud", 15, anything)
      end

      it "uses 60s TTL for stock" do
        described_class.fetch("price:stock:aapl:aud", asset_type: "stock") { { asset: "AAPL" } }
        expect(redis_double).to have_received(:setex).with("price:stock:aapl:aud", 60, anything)
      end

      it "uses 300s TTL for fx" do
        described_class.fetch("price:fx:usd:aud", asset_type: "fx") { { asset: "USD" } }
        expect(redis_double).to have_received(:setex).with("price:fx:usd:aud", 300, anything)
      end

      it "uses default TTL for unknown asset type" do
        described_class.fetch("price:unknown:xyz:aud", asset_type: "unknown") { { asset: "XYZ" } }
        expect(redis_double).to have_received(:setex).with("price:unknown:xyz:aud", 60, anything)
      end
    end

    context "when Redis is down" do
      it "falls through to the block without raising" do
        allow(redis_double).to receive(:get).and_raise(Redis::BaseError)

        result = described_class.fetch("price:fx:usd:aud", asset_type: "fx") { { asset: "USD", price: 1.55 } }

        expect(result[:asset]).to eq("USD")
      end

      it "logs a warning when Redis is down" do
        allow(redis_double).to receive(:get).and_raise(Redis::BaseError.new("connection refused"))

        expect {
          described_class.fetch("price:fx:usd:aud", asset_type: "fx") { { asset: "USD" } }
        }.to output(/Cache error.*connection refused/).to_stderr
      end
    end
  end
end