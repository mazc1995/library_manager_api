require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:book) { create(:book) }
  describe "GET /index" do
    it "returns http success" do
      get "/books"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/books/#{book.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
