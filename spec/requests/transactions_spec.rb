require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  let!(:user) { create(:user) }
  let!(:team) { create(:team, owner: user) }
  let!(:user_wallet) { create(:wallet, walletable: user.entity) }
  let!(:team_wallet) { create(:wallet, walletable: team.entity) }

  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.credentials.dig(:jwt, :secret_key)) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "GET /users/:user_id/wallets/transactions" do
    before do
      create(:transaction, sender_wallet: user_wallet, receiver_wallet: team_wallet, amount: 100.0)
    end

    context "when user is authorized" do
      it "retrieves the user's transactions" do
        get "/users/#{user.id}/wallets/transactions", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["transactions"]).to be_present
      end
    end

    context "when user is unauthorized" do
      it "returns an unauthorized error" do
        get "/users/#{user.id}/wallets/transactions"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["message"]).to eq("Please log in")
      end
    end
  end

  describe "GET /teams/:team_id/wallets/transactions" do
    before do
      create(:transaction, sender_wallet: team_wallet, receiver_wallet: user_wallet, amount: 50.0)
    end

    context "when team leader is authorized" do
      it "retrieves the team's transactions" do
        get "/teams/#{team.id}/wallets/transactions", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["transactions"]).to be_present
      end
    end

    context "when team leader is unauthorized" do
      it "returns an unauthorized error" do
        unauthorized_user = create(:user)
        unauthorized_token = JWT.encode({ user_id: unauthorized_user.id }, Rails.application.credentials.dig(:jwt, :secret_key))
        unauthorized_headers = { 'Authorization' => "Bearer #{unauthorized_token}" }

        get "/teams/#{team.id}/wallets/transactions", headers: unauthorized_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["message"]).to eq("Unauthorized access")
      end
    end
  end

  describe "error handling" do
    context "when the wallet is not found" do
      it "returns a not found error" do
        allow(Wallet).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)

        get "/users/#{user.id}/wallets/transactions", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Wallet not found")
      end
    end
  end
end
