require 'rails_helper'

RSpec.describe 'User', type: :request do
  describe 'POST /user' do
    let(:valid_params) { { name: 'Jane Doe', email: 'jane@example.com', password: 'password' } }
    let(:invalid_params) { { name: '', email: 'invalid-email', password: '' } }

    context 'with valid parameters' do
      it 'creates a new user and returns a token' do
        post '/user', params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user']).to include('id', 'name', 'email')
        expect(json['token']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post '/user', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank", "Email is invalid", "Password can't be blank")
      end
    end
  end
end
