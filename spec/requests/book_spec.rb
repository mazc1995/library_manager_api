require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }
  let(:book) { create(:book) }
  
  describe "GET /index" do
    context "when user is authenticated (any role)" do
      it "returns http success for member" do
        get "/books", headers: auth_headers(member)
        expect(response).to have_http_status(:success)
      end

      it "returns http success for librarian" do
        get "/books", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        get "/books"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /show" do
    context "when user is authenticated (any role)" do
      it "returns http success for member" do
        get "/books/#{book.id}", headers: auth_headers(member)
        expect(response).to have_http_status(:success)
      end

      it "returns http success for librarian" do
        get "/books/#{book.id}", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        get "/books/#{book.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /create" do
    let(:book_params) do
      { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 1, available: true }
    end

    context "when user is a librarian" do
      it "returns http success" do
        post "/books", params: book_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is a member" do
      it "returns unauthorized (only librarians can create books)" do
        post "/books", params: book_params, headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        post "/books", params: book_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /update" do
    let(:book_params) do
      { title: "The Great Gatsby Updated", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "1234567890", copies: 2, available: true }
    end

    context "when user is a librarian" do
      it "returns http success" do
        put "/books/#{book.id}", params: book_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is a member" do
      it "returns unauthorized (only librarians can update books)" do
        put "/books/#{book.id}", params: book_params, headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        put "/books/#{book.id}", params: book_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user is a librarian" do
      it "returns http success" do
        delete "/books/#{book.id}", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is a member" do
      it "returns unauthorized (only librarians can delete books)" do
        delete "/books/#{book.id}", headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        delete "/books/#{book.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
