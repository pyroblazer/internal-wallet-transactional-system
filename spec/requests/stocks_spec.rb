require 'rails_helper'

RSpec.describe "Stocks", type: :request do
  let!(:user) { create(:user) }
  let!(:stock) { create(:stock) }
  let!(:stock_wallet) { create(:wallet, walletable: stock.entity, balance: 0) }

  describe "GET /stocks" do
    let(:token) { JWT.encode({ user_id: user.id }, Rails.application.credentials.dig(:jwt, :secret_key)) }
    let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

    it "returns a list of stocks" do
      get stocks_path, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(json['stocks']).not_to be_empty
    end
  end

  describe "Users resource" do
    let(:token) { JWT.encode({ user_id: user.id }, Rails.application.credentials.dig(:jwt, :secret_key)) }
    let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
    let!(:investor_wallet) { create(:wallet, walletable: user.entity, balance: 1000) }

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
  end

  describe "Teams resource" do
    let!(:team) { create(:team, owner: user) }
    let(:token) { JWT.encode({ user_id: team.owner_id }, Rails.application.credentials.dig(:jwt, :secret_key)) }
    let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
    let!(:investor_wallet) { create(:wallet, walletable: team.entity, balance: 1000) }

    describe "POST /teams/:team_id/stocks/invest" do
      context "with sufficient funds" do
        it "invests in a stock for a team" do
          post invest_team_stocks_path(team_id: team.id), params: { stock_id: stock.id, amount: 500 }, headers: auth_headers
          expect(response).to have_http_status(:ok)
          expect(json['message']).to match(/Investment of 500.0 in stock .+ has been successfully processed./)
          expect(json['data']['wallet_balance'].to_f).to eq(investor_wallet.reload.balance)
        end
      end

      context "with insufficient funds" do
        it "returns an error message" do
          post invest_team_stocks_path(team_id: team.id), params: { stock_id: stock.id, amount: 1500 }, headers: auth_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['message']).to eq("Insufficient funds available.")
        end
      end
    end

    describe "POST /teams/:team_id/stocks/update_price" do
      context "with valid parameters" do
        it "updates the stock price and adjusts the wallets for a team" do
          post update_price_team_stocks_path(team_id: team.id), params: { stock_id: stock.id, new_price: 200 }, headers: auth_headers
          expect(response).to have_http_status(:ok)
          expect(json['data']['stock']['price'].to_f).to eq(200.0)
        end
      end

      context "with invalid parameters" do
        it "returns an error message" do
          post update_price_team_stocks_path(team_id: team.id), params: { stock_id: 999, new_price: 200 }, headers: auth_headers
          expect(response).to have_http_status(:not_found)
          expect(json['error']).to eq("Stock not found")
        end
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
