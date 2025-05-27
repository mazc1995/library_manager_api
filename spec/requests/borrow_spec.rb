require 'rails_helper'

RSpec.describe "Borrows", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, copies: 1, available: true) }
  let(:borrow) { create(:borrow, user: user, book: book) }

  describe "GET /index" do
    it "returns http success" do
      get "/borrows"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/borrows/#{borrow.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success and reduces book copies" do
      post "/borrows", params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
      expect(response).to have_http_status(:success)
      expect(Book.find(book.id).copies).to eq(0)
      expect(Book.find(book.id).available).to eq(false)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success and increases book copies" do
      # Primero prestamos el libro para que copies sea 0
      post "/borrows", params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
      borrow = Borrow.last
      delete "/borrows/#{borrow.id}"
      expect(response).to have_http_status(:success)
      expect(Book.find(book.id).copies).to eq(1)
      expect(Book.find(book.id).available).to eq(true)
    end
  end
end