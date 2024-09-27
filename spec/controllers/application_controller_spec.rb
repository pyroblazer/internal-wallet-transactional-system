require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :authorized

    def index
      render json: { message: 'Success' }, status: :ok
    end
  end

  let!(:user) { create(:user) }
  let(:token) { JWT.encode({ user_id: user.id }, ENV["JWT_SECRET_KEY"]) }

  describe 'Authorization' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
      end

      it 'allows access' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Success')
      end
    end

    context 'with no token' do
      it 'denies access' do
        get :index

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Please log in')
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :index
      end

      it 'denies access' do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Please log in')
      end
    end
  end
end
