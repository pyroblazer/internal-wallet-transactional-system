require 'rails_helper'

RSpec.describe "Teams", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { { name: "New Team" } }
  let(:token) { JWT.encode({ user_id: user.id }, ENV["JWT_SECRET_KEY"]) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  describe "POST /teams" do
    context "when user is authorized" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it "creates a new team and returns the team details" do
        expect {
          post "/teams", params: valid_attributes, headers: auth_headers
        }.to change(Team, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['team']['name']).to eq(valid_attributes[:name])
        expect(json_response['team']['owner_id']).to eq(user.id)
        expect(json_response['team']['size']).to eq(1)
      end
    end

    context "when user is not authorized" do
      it "returns an unauthorized error" do
        post "/teams", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when invalid parameters are provided" do
      it "returns an unprocessable entity error" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        invalid_attributes = { name: "" }

        post "/teams", params: invalid_attributes, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end
  end
end
