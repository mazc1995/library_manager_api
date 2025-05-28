require 'rails_helper'

RSpec.describe "Borrows", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }
  let(:book) { create(:book, copies: 1, available: true) }
  let(:borrow) { create(:borrow, user: member, book: book) }

  describe "GET /index" do
    context "when user is authenticated (any role)" do
      it "returns http success for member" do
        get "/borrows", headers: auth_headers(member)
        expect(response).to have_http_status(:success)
      end

      it "returns http success for librarian" do
        get "/borrows", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        get "/borrows"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /show" do
    context "when user is authenticated (any role)" do
      it "returns http success for member" do
        get "/borrows/#{borrow.id}", headers: auth_headers(member)
        expect(response).to have_http_status(:success)
      end

      it "returns http success for librarian" do
        get "/borrows/#{borrow.id}", headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        get "/borrows/#{borrow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /create" do
    let(:borrow_params) do
      { user_id: member.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
    end

    context "when user is a member" do
      it "returns http success and reduces book copies" do
        post "/borrows", params: borrow_params, headers: auth_headers(member)
        expect(response).to have_http_status(:success)
        expect(Book.find(book.id).copies).to eq(0)
        expect(Book.find(book.id).available).to eq(false)
      end
    end

    context "when user is a librarian" do
      it "returns unauthorized (only members can create borrows)" do
        post "/borrows", params: borrow_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only members can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        post "/borrows", params: borrow_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /update" do
    context "when user is a librarian" do
      it "returns http success and increases book copies" do
        put "/borrows/#{borrow.id}", 
            params: { returned: true, returned_date: DateTime.now },
            headers: auth_headers(librarian)
        expect(response).to have_http_status(:success)
        expect(Book.find(book.id).copies).to eq(2)
        expect(Book.find(book.id).available).to eq(true)
        expect(Borrow.find(borrow.id).returned).to eq(true)
        expect(Borrow.find(borrow.id).returned_date.to_i).to be_within(1).of(DateTime.now.to_i)
      end
    end

    context "when user is a member" do
      it "returns unauthorized (only librarians can update borrows)" do
        put "/borrows/#{borrow.id}", 
            params: { returned: true, returned_date: DateTime.now },
            headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Only librarians can perform this action')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        put "/borrows/#{borrow.id}", params: { returned: true, returned_date: DateTime.now }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when user is authenticated (only librarians can delete borrows)" do
      let(:test_borrow) { create(:borrow, user: member, book: book, borrow_date: Date.today - 7.days, due_date: Date.today + 7.days) }
      
      it "returns success when librarian deletes a borrow" do
        delete "/borrows/#{test_borrow.id}", headers: auth_headers(librarian)
        expect(response).to have_http_status(:no_content)
      end
      
      it "returns unauthorized when member tries to delete a borrow" do
        delete "/borrows/#{test_borrow.id}", headers: auth_headers(member)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized without token" do
        delete "/borrows/#{borrow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end