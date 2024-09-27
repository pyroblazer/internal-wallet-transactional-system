require 'rails_helper'

RSpec.describe "Stocks", type: :request do
  let!(:user) { create(:user) }
  let!(:team) { create(:team) }
  let!(:stock) { create(:stock) }
  let!(:investor_wallet) { create(:wallet, walletable: user.entity, balance: 1000) }
  let!(:stock_wallet) { create(:wallet, walletable: stock.entity, balance: 0) }
  let(:token) { JWT.encode({ user_id: user.id }, ENV["JWT_SECRET_KEY"]) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /stocks" do
    it "returns a list of stocks" do
      get stocks_path, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(json['stocks']).not_to be_empty
    end
  end

  describe "POST /users/:user_id/stocks/invest" do
    context "with sufficient funds" do
      it "invests in a stock" do
        post invest_user_stocks_path(user_id: user.id), params: { stock_id: stock.id, amount: 500 }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json['message']).to match(/Investment of 500.0 in stock .+ has been successfully processed./)
        expect(json['data']['wallet_balance'].to_f).to eq(investor_wallet.reload.balance)
      end
    end

    context "with insufficient funds" do
      it "returns an error message" do
        post invest_user_stocks_path(user_id: user.id), params: { stock_id: stock.id, amount: 1500 }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['message']).to eq("Insufficient funds available.")
      end
    end
  end

  describe "POST /users/:user_id/stocks/update_price" do
    context "with valid parameters" do
      it "updates the stock price and adjusts the wallets" do
        post update_price_user_stocks_path(user_id: user.id), params: { stock_id: stock.id, new_price: 200 }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json['data']['stock']['price'].to_f).to eq(200.0)
      end
    end

    context "with invalid parameters" do
      it "returns an error message" do
        post update_price_user_stocks_path(user_id: user.id), params: { stock_id: 999, new_price: 200 }, headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq("Stock not found")
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
