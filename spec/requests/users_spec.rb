require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }
  let(:book) { create(:book) }

  before do
    # Create some borrows for the member
    create(:borrow, user: member, book: book, borrow_date: Date.current - 7.days, due_date: Date.current + 7.days, returned: false)
    create(:borrow, user: member, book: book, borrow_date: Date.current - 14.days, due_date: Date.current - 7.days, returned: true, returned_date: Date.current - 10.days)
  end

  describe "GET /users" do
    context "when user is a librarian" do
      it "returns list of users" do
        get "/users", headers: auth_headers(librarian)
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to be >= 2 # at least member and librarian
      end
    end

    context "when user is a member" do
      it "returns unauthorized" do
        get "/users", headers: auth_headers(member)
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/users"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /users/:id" do
    context "when user is a librarian" do
      it "returns user details with borrows" do
        get "/users/#{member.id}", headers: auth_headers(librarian)
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        
        expect(json_response['id']).to eq(member.id)
        expect(json_response['name']).to eq(member.name)
        expect(json_response['email']).to eq(member.email)
        expect(json_response['role']).to eq(member.role)
        
        expect(json_response['borrows']).to be_an(Array)
        expect(json_response['borrows'].length).to eq(2)
        
        # Check if borrows have the expected attributes
        first_borrow = json_response['borrows'].first
        expect(first_borrow).to have_key('book_title')
        expect(first_borrow).to have_key('book_author')
        expect(first_borrow).to have_key('book_genre')
        expect(first_borrow).to have_key('borrow_date')
        expect(first_borrow).to have_key('due_date')
        expect(first_borrow).to have_key('is_overdue')
      end
    end

    context "when user is a member" do
      it "returns unauthorized" do
        get "/users/#{member.id}", headers: auth_headers(member)
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/users/#{member.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 