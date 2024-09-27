require 'rails_helper'

RSpec.describe "Wallets", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JWT.encode({ user_id: user.id }, ENV["JWT_SECRET_KEY"]) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
  let!(:wallet) { create(:wallet, walletable: user.entity, balance: 100.0) }
  let(:amount) { 100.0 }

  describe "GET /users/:user_id/wallets" do
    context "when authorized" do
      it "retrieves the wallet for the user" do
        get "/users/#{user.id}/wallets", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["wallet"]["balance"].to_f).to eq(wallet.balance.to_f)
      end
    end

    context "when unauthorized" do
      it "returns an unauthorized error" do
        get "/users/#{user.id}/wallets"
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["message"]).to eq("Please log in")
      end
    end
  end

  describe "POST /users/:user_id/wallets/deposit" do
    context "when authorized" do
      it "tops up the user's wallet" do
        post "/users/#{user.id}/wallets/deposit", params: { amount: amount }, headers: auth_headers

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq("Deposited #{amount} successfully")
        expect(parsed_response["data"]["wallet_balance"].to_f).to eq((wallet.reload.balance).to_f)
      end
    end

    context "with invalid amount" do
      it "returns an error when amount is blank" do
        post "/users/#{user.id}/wallets/deposit", params: { amount: nil }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Deposit amount must be greater than 0")
      end

      it "returns an error when amount is 0" do
        post "/users/#{user.id}/wallets/deposit", params: { amount: 0 }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Deposit amount must be greater than 0")
      end

      it "returns an error when amount is negative" do
        post "/users/#{user.id}/wallets/deposit", params: { amount: -50.0 }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Deposit amount must be greater than 0")
      end
    end
  end

  describe "POST /users/:user_id/wallets/transfer" do
    let!(:receiver) { create(:user) }
    let!(:receiver_wallet) { create(:wallet, walletable: receiver.entity, balance: 0.0) }
    let(:transfer_amount) { 50.0 }

    context "when authorized" do
      it "transfers funds to another user's wallet" do
        post "/users/#{user.id}/wallets/transfer", params: { amount: transfer_amount, receiver_wallet_id: receiver_wallet.id }, headers: auth_headers

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq("Transferred #{transfer_amount} successfully")
        expect(parsed_response["data"]["wallet_balance"].to_f).to eq(wallet.reload.balance.to_f)

        expect(receiver_wallet.reload.balance.to_f).to eq(transfer_amount)
      end
    end

    context "with invalid transfer amount" do
      it "returns an error when amount is 0" do
        post "/users/#{user.id}/wallets/transfer", params: { amount: 0, receiver_wallet_id: receiver_wallet.id }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Transfer amount must be greater than 0")
      end

      it "returns an error when amount is negative" do
        post "/users/#{user.id}/wallets/transfer", params: { amount: -10.0, receiver_wallet_id: receiver_wallet.id }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Transfer amount must be greater than 0")
      end
    end

    context "when unauthorized" do
      it "returns an unauthorized error" do
        post "/users/#{user.id}/wallets/transfer", params: { amount: 50.0, receiver_wallet_id: receiver_wallet.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["message"]).to eq("Please log in")
      end
    end
  end
end
