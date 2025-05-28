require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /signup" do
    let(:valid_params) do
      {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          role: "member"
        }
      }
    end

    it "creates a new user and returns a token" do
      post "/signup", params: valid_params
      expect(response).to have_http_status(:created)
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('token')
      expect(json_response['token']).to be_present
    end

    it "returns errors for invalid params" do
      post "/signup", params: { user: { email: "invalid" } }
      expect(response).to have_http_status(:unprocessable_entity)
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('errors')
    end
  end

  describe "POST /login" do
    let(:user) { create(:user, email: "test@example.com", password: "password123") }

    it "returns a token for valid credentials" do
      post "/login", params: { email: user.email, password: "password123" }
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('token')
      expect(json_response['token']).to be_present
    end

    it "returns error for invalid credentials" do
      post "/login", params: { email: user.email, password: "wrongpassword" }
      expect(response).to have_http_status(:unauthorized)
      
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('error')
    end
  end

  describe "DELETE /logout" do
    let(:user) { create_authenticated_user }

    it "logs out the user successfully" do
      delete "/logout", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Logged out successfully')
    end

    it "returns unauthorized without token" do
      delete "/logout"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
