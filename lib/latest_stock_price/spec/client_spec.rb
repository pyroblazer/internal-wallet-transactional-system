# frozen_string_literal: true

require "latest_stock_price"
require "webmock/rspec"

RSpec.describe LatestStockPrice::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key) }
  let(:base_url) { "https://latest-stock-price.p.rapidapi.com/any" }
  let(:headers) do
    {
      "x-rapidapi-host" => LatestStockPrice::Client::RAPIDAPI_HOST,
      "x-rapidapi-key" => api_key
    }
  end

  describe "#price_all" do
    context "when the API response is successful" do
      let(:response_body) do
        [
          { "symbol" => "AAPL", "price" => 150.75 },
          { "symbol" => "GOOGL", "price" => 2800.50 }
        ].to_json
      end

      before do
        stub_request(:get, base_url)
          .with(headers: headers)
          .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
      end

      it "returns parsed JSON response" do
        result = client.price_all
        expect(result).to be_an(Array)
        expect(result.first["symbol"]).to eq("AAPL")
        expect(result.first["price"]).to eq(150.75)
      end
    end

    context "when the API response is an error" do
      before do
        stub_request(:get, base_url)
          .with(headers: headers)
          .to_return(status: 500, exception: "Internal Server Error")
      end

      it "raises a StandardError" do
        expect { client.price_all }.to raise_error(
          StandardError
        )
      end
    end
  end
end
