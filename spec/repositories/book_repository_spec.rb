require 'rails_helper'

RSpec.describe BookRepository, type: :model do
  let!(:book1) { Book.create!(title: 'The Lord of the Rings', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: '123', copies: 5, available: true) }
  let!(:book2) { Book.create!(title: 'The Hobbit', author: 'j.r.r. tolkien', genre: 'fantasy', isbn: '456', copies: 3, available: false) }
  let!(:book3) { Book.create!(title: '1984', author: 'George Orwell', genre: 'Dystopian', isbn: '789', copies: 2, available: true) }

  subject { described_class.new }

  it 'finds books by partial, case-insensitive title' do
    expect(subject.list_books(title: 'lord')).to include(book1)
    expect(subject.list_books(title: 'LORD')).to include(book1)
    expect(subject.list_books(title: 'hob')).to include(book2)
  end

  it 'finds books by partial, case-insensitive author' do
    expect(subject.list_books(author: 'tolkien')).to include(book1, book2)
    expect(subject.list_books(author: 'TOLKIEN')).to include(book1, book2)
  end

  it 'finds books by partial, case-insensitive genre' do
    expect(subject.list_books(genre: 'fant')).to include(book1, book2)
    expect(subject.list_books(genre: 'DYSTOPIAN')).to include(book3)
  end

  it 'finds books by partial, case-insensitive isbn' do
    expect(subject.list_books(isbn: '123')).to include(book1)
    expect(subject.list_books(isbn: '12')).to include(book1)
    expect(subject.list_books(isbn: '000')).to be_empty
  end

  it 'finds books by available status' do
    expect(subject.list_books(available: true)).to include(book1, book3)
    expect(subject.list_books(available: false)).to include(book2)
  end

  it 'combines filters' do
    expect(subject.list_books(author: 'tolkien', available: true)).to include(book1)
    expect(subject.list_books(author: 'tolkien', available: false)).to include(book2)
    expect(subject.list_books(author: 'tolkien', genre: 'fantasy')).to include(book1, book2)
    expect(subject.list_books(author: 'tolkien', genre: 'dystopian')).to be_empty
  end
end 