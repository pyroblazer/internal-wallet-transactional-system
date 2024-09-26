require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  before(:all) do
    @user = create(:user, email: 'john@example.com', password: 'password')
  end

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'returns a user and a token' do
        post '/auth/login', params: { email: 'john@example.com', password: 'password' }

        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json['user']).to include('id', 'name', 'email')
        expect(json['token']).to be_present
      end
    end

    context 'with wrong password' do
      it 'returns an invalid email or password error with unauthorized status' do
        post '/auth/login', params: { email: 'john@example.com', password: 'wrong_password' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Invalid email or password')
      end
    end

    context 'with non-existent email' do
      it 'returns an invalid email or password error with unauthorized status' do
        post '/auth/login', params: { email: 'nonexistent@example.com', password: 'password' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['message']).to eq("Invalid email or password")
      end
    end
  end
end
