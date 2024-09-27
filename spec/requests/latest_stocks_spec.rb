require 'rails_helper'

RSpec.describe "LatestStocks", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.credentials.dig(:jwt, :secret_key)) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    allow_any_instance_of(LatestStockPrice::Client).to receive(:price_all).and_return(mocked_prices)
  end

  let(:mocked_prices) do
    [
      { "symbol" => "AAPL", "price" => 150.00 },
      { "symbol" => "GOOGL", "price" => 2800.00 }
    ]
  end

  describe "GET /stocks/price_all" do
    context "when the user is authorized" do
      it "returns the list of stock prices" do
        get "/stocks/price_all", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(mocked_prices.as_json)
      end
    end

    context "when the user is unauthorized" do
      it "returns a 401 status" do
        get "/stocks/price_all"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "error handling" do
    context "when a record is not found" do
      it "returns a 404 status with error message" do
        allow_any_instance_of(LatestStockPrice::Client).to receive(:price_all).and_raise(ActiveRecord::RecordNotFound)

        get "/stocks/price_all", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Latest stock not found")
      end
    end

    context "when a record is invalid" do
      it "returns a 422 status with error message" do
        invalid_stock = Stock.new
        invalid_stock.errors.add(:base, "Invalid stock data")
        allow_any_instance_of(LatestStockPrice::Client).to receive(:price_all).and_raise(ActiveRecord::RecordInvalid.new(invalid_stock))

        get "/stocks/price_all", headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end
  end
end
