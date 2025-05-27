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

  describe "POST /create" do
    it "returns http success" do
      post "/books", params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /update" do
    it "returns http success" do
      put "/books/#{book.id}", params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true }
      expect(response).to have_http_status(:success)
    end
  end
end
