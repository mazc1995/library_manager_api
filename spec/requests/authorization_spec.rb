require 'rails_helper'

RSpec.describe "Authorization", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }

  describe "Role-based authorization" do
    context "when testing librarian-only endpoints" do
      it "allows librarians to access librarian-only actions" do
        post "/books", 
             params: { title: "Test Book", author: "Test Author", genre: "Test", isbn: "123456", copies: 1 },
             headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end

      it "denies members access to librarian-only actions" do
        post "/books", 
             params: { title: "Test Book", author: "Test Author", genre: "Test", isbn: "123456", copies: 1 },
             headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when testing member-only endpoints" do
      let(:book) { create(:book, copies: 1) }

      it "allows members to access member-only actions" do
        post "/borrows", 
             params: { user_id: member.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week },
             headers: auth_headers(member)
        expect(response).to have_http_status(:success)
      end

      it "denies librarians access to member-only actions" do
        post "/borrows", 
             params: { user_id: member.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week },
             headers: auth_headers(librarian)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only members can perform this action')
      end
    end

    context "when testing general authenticated endpoints" do
      it "allows any authenticated user to access general endpoints" do
        get "/books", headers: auth_headers(member)
        expect(response).to have_http_status(:success)

        get "/books", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end

      it "denies unauthenticated users access to any endpoint" do
        get "/books"
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end

  describe "Authentication token validation" do
    it "accepts valid tokens" do
      get "/books", headers: auth_headers(member)
      expect(response).to have_http_status(:success)
    end

    it "rejects invalid tokens" do
      get "/books", headers: { 'Authorization' => 'Bearer invalid_token' }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects malformed authorization headers" do
      get "/books", headers: { 'Authorization' => 'invalid_format' }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects missing authorization headers" do
      get "/books"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end 