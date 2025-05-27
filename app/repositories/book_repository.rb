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
end