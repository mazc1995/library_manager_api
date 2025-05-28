require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:user) { create_authenticated_user }
  let(:book) { create(:book) }
  
  describe "GET /index" do
    it "returns http success" do
      get "/books", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      get "/books"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/books/#{book.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      get "/books/#{book.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/books", 
           params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true },
           headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      post "/books", params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /update" do
    it "returns http success" do
      put "/books/#{book.id}", 
          params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true },
          headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      put "/books/#{book.id}", params: { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/books/#{book.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      delete "/books/#{book.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
