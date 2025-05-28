require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }
  let(:book1) { create(:book, title: "Book 1", author: "Author 1") }
  let(:book2) { create(:book, title: "Book 2", author: "Author 2") }

  describe "GET /dashboard" do
    context "when user is a librarian" do
      before do
        # Create test data for librarian dashboard
        create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current)
        create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 14.days, due_date: Date.current - 1.day)
      end

      it "returns librarian dashboard data" do
        get "/dashboard", headers: auth_headers(librarian)
        
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('total_books')
        expect(json_response).to have_key('total_borrowed_books')
        expect(json_response).to have_key('books_due_today')
        expect(json_response).to have_key('members_with_overdue_books')
        
        expect(json_response['total_books']).to eq(2)
        expect(json_response['total_borrowed_books']).to eq(2)
        expect(json_response['books_due_today']).to eq(1)
        expect(json_response['members_with_overdue_books']).to be_an(Array)
      end
    end

    context "when user is a member" do
      before do
        # Create test data for member dashboard
        create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current + 3.days)
        create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 14.days, due_date: Date.current - 1.day)
      end

      it "returns member dashboard data" do
        get "/dashboard", headers: auth_headers(member)
        
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('borrowed_books')
        expect(json_response).to have_key('overdue_books')
        
        expect(json_response['borrowed_books']).to be_an(Array)
        expect(json_response['borrowed_books'].length).to eq(2)
        expect(json_response['overdue_books']).to be_an(Array)
        expect(json_response['overdue_books'].length).to eq(1)
      end

      it "includes correct book information in borrowed books" do
        get "/dashboard", headers: auth_headers(member)
        
        json_response = JSON.parse(response.body)
        borrowed_book = json_response['borrowed_books'].first
        
        expect(borrowed_book).to have_key('borrow_id')
        expect(borrowed_book).to have_key('book_title')
        expect(borrowed_book).to have_key('book_author')
        expect(borrowed_book).to have_key('due_date')
        expect(borrowed_book).to have_key('days_until_due')
        expect(borrowed_book).to have_key('is_overdue')
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/dashboard"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user has invalid token" do
      it "returns unauthorized" do
        get "/dashboard", headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "Dashboard data accuracy" do
    context "for librarian dashboard" do
      before do
        # Create comprehensive test data
        member2 = create(:user, role: :member, name: "Member 2", email: "member2@test.com")
        
        # Books due today
        create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current)
        
        # Overdue books
        create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 10.days, due_date: Date.current - 2.days)
        create(:borrow, user: member2, book: book1, returned: false, borrow_date: Date.current - 5.days, due_date: Date.current - 1.day)
        
        # Returned books (should not count)
        create(:borrow, user: member, book: book2, returned: true, borrow_date: Date.current - 14.days, due_date: Date.current - 3.days)
      end

      it "correctly counts books due today" do
        get "/dashboard", headers: auth_headers(librarian)
        
        json_response = JSON.parse(response.body)
        expect(json_response['books_due_today']).to eq(1)
      end

      it "correctly identifies members with overdue books" do
        get "/dashboard", headers: auth_headers(librarian)
        
        json_response = JSON.parse(response.body)
        overdue_members = json_response['members_with_overdue_books']
        
        expect(overdue_members.length).to eq(2)
        
        member_with_overdue = overdue_members.find { |m| m['user_id'] == member.id }
        expect(member_with_overdue['overdue_books'].length).to eq(1)
        expect(member_with_overdue['overdue_books'].first['days_overdue']).to eq(2)
      end
    end

    context "for member dashboard" do
      before do
        # Create test borrows for the member
        create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 10.days, due_date: Date.current + 5.days)
        create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 14.days, due_date: Date.current - 3.days)
        
        # Create borrow for another member (should not appear)
        other_member = create(:user, role: :member)
        create(:borrow, user: other_member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current + 1.day)
      end

      it "only shows books for the authenticated member" do
        get "/dashboard", headers: auth_headers(member)
        
        json_response = JSON.parse(response.body)
        borrowed_books = json_response['borrowed_books']
        
        expect(borrowed_books.length).to eq(2)
        borrowed_books.each do |book|
          expect(book['book_title']).to be_in([book1.title, book2.title])
        end
      end

      it "correctly calculates days until due and overdue" do
        get "/dashboard", headers: auth_headers(member)
        
        json_response = JSON.parse(response.body)
        borrowed_books = json_response['borrowed_books']
        
        future_book = borrowed_books.find { |b| b['book_title'] == book1.title }
        overdue_book = borrowed_books.find { |b| b['book_title'] == book2.title }
        
        expect(future_book['days_until_due']).to eq(5)
        expect(future_book['is_overdue']).to be false
        
        expect(overdue_book['days_until_due']).to eq(-3)
        expect(overdue_book['is_overdue']).to be true
      end
    end
  end
end 