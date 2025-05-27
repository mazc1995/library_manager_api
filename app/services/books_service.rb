class BooksService
  def list_books(filters)
    # receive filters of model Book
    # return all books that match the filters
    # title, author and genre are case insensitive and partial match for improve user experience
    # return class Active Record Relation
    BookRepository.new.list_books(filters)
  end

  def show_book(id)
    # receive id
    # return the book
    BookRepository.new.show_book(id)
  end

  def create_book(book_params)
    # receive book_params
    # return the book
    BookRepository.new.create_book(book_params)
  end

  def update_book(id, book_params)
    # receive id and book_params
    # update the book
    BookRepository.new.update_book(id, book_params)
  end

  def destroy_book(id)
    # receive id
    # destroy the book
    BookRepository.new.destroy_book(id)
  end
end