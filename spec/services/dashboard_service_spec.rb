require 'rails_helper'

RSpec.describe DashboardService, type: :service do
  let(:service) { described_class.new }
  let(:member) { create(:user, role: :member) }
  let(:librarian) { create(:user, role: :librarian) }
  let(:book1) { create(:book, title: "Book 1", author: "Author 1") }
  let(:book2) { create(:book, title: "Book 2", author: "Author 2") }

  describe '#librarian_dashboard' do
    before do
      # Create some test data
      create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current)
      create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 10.days, due_date: Date.current - 2.days)
      create(:borrow, user: member, book: book1, returned: true, borrow_date: Date.current - 14.days, due_date: Date.current - 1.day)
    end

    let(:dashboard_data) { service.librarian_dashboard }

    it 'returns the correct structure' do
      expect(dashboard_data).to have_key(:total_books)
      expect(dashboard_data).to have_key(:total_borrowed_books)
      expect(dashboard_data).to have_key(:books_due_today)
      expect(dashboard_data).to have_key(:members_with_overdue_books)
    end

    it 'returns correct total books count' do
      expect(dashboard_data[:total_books]).to eq(2)
    end

    it 'returns correct total borrowed books count' do
      expect(dashboard_data[:total_borrowed_books]).to eq(2)
    end

    it 'returns correct books due today count' do
      expect(dashboard_data[:books_due_today]).to eq(1)
    end

    it 'returns members with overdue books' do
      overdue_members = dashboard_data[:members_with_overdue_books]
      expect(overdue_members).to be_an(Array)
      expect(overdue_members.length).to eq(1)
      
      member_data = overdue_members.first
      expect(member_data[:user_id]).to eq(member.id)
      expect(member_data[:user_name]).to eq(member.name)
      expect(member_data[:overdue_books]).to be_an(Array)
      expect(member_data[:overdue_books].length).to eq(1)
    end
  end

  describe '#member_dashboard' do
    before do
      # Create test borrows for the member
      create(:borrow, user: member, book: book1, returned: false, borrow_date: Date.current - 7.days, due_date: Date.current + 3.days)
      create(:borrow, user: member, book: book2, returned: false, borrow_date: Date.current - 10.days, due_date: Date.current - 1.day)
      create(:borrow, user: member, book: book1, returned: true, borrow_date: Date.current - 14.days, due_date: Date.current - 5.days)
    end

    let(:dashboard_data) { service.member_dashboard(member) }

    it 'returns the correct structure' do
      expect(dashboard_data).to have_key(:borrowed_books)
      expect(dashboard_data).to have_key(:overdue_books)
    end

    it 'returns borrowed books with correct information' do
      borrowed_books = dashboard_data[:borrowed_books]
      expect(borrowed_books).to be_an(Array)
      expect(borrowed_books.length).to eq(2)
      
      book_data = borrowed_books.first
      expect(book_data).to have_key(:borrow_id)
      expect(book_data).to have_key(:book_title)
      expect(book_data).to have_key(:due_date)
      expect(book_data).to have_key(:days_until_due)
      expect(book_data).to have_key(:is_overdue)
    end

    it 'returns overdue books' do
      overdue_books = dashboard_data[:overdue_books]
      expect(overdue_books).to be_an(Array)
      expect(overdue_books.length).to eq(1)
      
      overdue_book = overdue_books.first
      expect(overdue_book[:book_title]).to eq(book2.title)
      expect(overdue_book[:days_overdue]).to eq(1)
    end

    it 'correctly identifies overdue status' do
      borrowed_books = dashboard_data[:borrowed_books]
      
      future_due_book = borrowed_books.find { |b| b[:book_title] == book1.title }
      overdue_book = borrowed_books.find { |b| b[:book_title] == book2.title }
      
      expect(future_due_book[:is_overdue]).to be false
      expect(overdue_book[:is_overdue]).to be true
    end
  end
end 