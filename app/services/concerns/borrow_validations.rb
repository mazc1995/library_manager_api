module BorrowValidations
  extend ActiveSupport::Concern

  def validate_book_availability!(book_id)
    # validate if the book is available
    # if not available, raise an error
    book = BookRepository.new.show_book(book_id)
    raise "Book is not available" unless book.available?
  end

  def validate_user_borrowed_book!(user_id, book_id)
    # validate if the user has already borrowed the book
    # if so, raise an error
    raise "User already borrowed this book" if BorrowRepository.new.show_borrow({user_id: user_id, book_id: book_id, returned: false}).present?
  end

  def validate_borrow_returned!(borrow_id)
    # validate if the borrow was already returned
    # if so, raise an error
    borrow = BorrowRepository.new.show_borrow({id: borrow_id})
    raise "Borrow was already returned" if borrow.returned
  end
end