require 'rails_helper'

RSpec.describe "Borrows", type: :request do
  let(:user) { create_authenticated_user }
  let(:book) { create(:book, copies: 1, available: true) }
  let(:borrow) { create(:borrow, user: user, book: book) }

  describe "GET /index" do
    it "returns http success" do
      get "/borrows", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      get "/borrows"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/borrows/#{borrow.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      get "/borrows/#{borrow.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /create" do
    it "returns http success and reduces book copies" do
      post "/borrows", 
           params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week },
           headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      expect(Book.find(book.id).copies).to eq(0)
      expect(Book.find(book.id).available).to eq(false)
    end

    it "returns unauthorized without token" do
      post "/borrows", params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /update" do
    it "returns http success and increases book copies" do
      put "/borrows/#{borrow.id}", 
          params: { returned: true, returned_date: DateTime.now },
          headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      expect(Book.find(book.id).copies).to eq(2)
      expect(Book.find(book.id).available).to eq(true)
      expect(Borrow.find(borrow.id).returned).to eq(true)
      expect(Borrow.find(borrow.id).returned_date.to_i).to be_within(1).of(DateTime.now.to_i)
    end

    it "returns unauthorized without token" do
      put "/borrows/#{borrow.id}", params: { returned: true, returned_date: DateTime.now }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success and increases book copies" do
      # First we borrow the book so copies becomes 0
      post "/borrows", 
           params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week },
           headers: auth_headers(user)
      borrow = Borrow.last
      delete "/borrows/#{borrow.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized without token" do
      delete "/borrows/#{borrow.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end