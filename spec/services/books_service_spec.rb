require 'rails_helper'

RSpec.describe BooksService, type: :service do
  let!(:book) { Book.create!(title: 'Dune', author: 'Frank Herbert', genre: 'Science Fiction', isbn: '111', copies: 4, available: true) }

  describe '#list_books' do
    it 'delegates to BookRepository and returns matching books' do
      service = described_class.new
      result = service.list_books(title: 'dune')
      expect(result).to include(book)
    end
  end

  describe '#show_book' do
    it 'delegates to BookRepository and returns the book' do
      service = described_class.new
      result = service.show_book(book.id)
      expect(result).to eq(book)
    end
  end

  describe '#create_book' do
    it 'delegates to BookRepository and returns the book' do
      service = described_class.new
      expect { service.create_book(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Fiction', isbn: '1234567890', copies: 1, available: true) }.to change(Book, :count).by(1)
    end
  end

  describe '#update_book' do
    it 'delegates to BookRepository and returns the book' do
      service = described_class.new
      expect { service.update_book(book.id, title: 'The Great Gatsby') }.to change { book.reload.title }.to('The Great Gatsby')
    end
  end
end 