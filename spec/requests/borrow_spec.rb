require 'rails_helper'

RSpec.describe "Borrows", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
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
    it "returns http success" do
      post "/borrows", params: { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/borrows/#{borrow.id}"
      expect(response).to have_http_status(:success)
    end
  end
end