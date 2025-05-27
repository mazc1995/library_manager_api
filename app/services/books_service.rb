class BooksService
  def list_books(filters)
    # receive filters of model Book
    # return all books that match the filters
    # title, author and genre are case insensitive and partial match for improve user experience
    # return class Active Record Relation
    BookRepository.new.list_books(filters)
  end
end