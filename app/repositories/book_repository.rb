class BookRepository
  def list_books(filters)
    # receive filters of model Book
    # return all books that match the filters
    # title, author, genre and isbn are case insensitive and partial match for improve user experience
    # return class Active Record Relation
    books = Book.all

    filters.each do |key, value|
      case key.to_s
      when 'title', 'author', 'genre', 'isbn'
        books = books.where("#{key} ILIKE ?", "%#{value}%")
      else
        books = books.where(key => value)
      end
    end

    books
  end

  def show_book(id)
    # receive id
    # return the book
    Book.find(id)
  end

  def create_book(book_params)
    # receive book_params
    # create a new book
    Book.create!(book_params)
  end

  def update_book(id, book_params)
    # receive id and book_params
    # update the book
    Book.find(id).update!(book_params)
  end

  def destroy_book(id)
    # receive id
    # destroy the book
    Book.find(id).destroy!
  end
end