class BorrowsService
  include BorrowValidations

  def list_borrows(borrow_params)
    # receive borrow_params
    # return all borrows that match the filters
    BorrowRepository.new.list_borrows(borrow_params)
  end

  def show_borrow(id)
    BorrowRepository.new.show_borrow({id: id})
  end

  def create_borrow(borrow_params)
    # receive borrow_params
    # A user is borrowing a book
    # Validate if the book is available
    # Update the book availability to false
    book = BookRepository.new.show_book(borrow_params[:book_id])
    user = UserRepository.new.show_user(borrow_params[:user_id])

    run_borrow_validations!(book.id, user.id)
    ActiveRecord::Base.transaction do
      BorrowRepository.new.create_borrow(borrow_params)
      BookRepository.new.update_book(book.id, { copies: book.copies - 1 })
    end
  end

  def destroy_borrow(id)
    # receive id
    # A user is returning a book
    # Update the book availability to true
    # Destroy the borrow

    ActiveRecord::Base.transaction do
      borrow = BorrowRepository.new.show_borrow({id: id})
      book = BookRepository.new.show_book(borrow.book_id)
      BookRepository.new.update_book(book.id, { copies: book.copies + 1 })
      BorrowRepository.new.destroy_borrow(id)
    end
  end

  private

  def run_borrow_validations!(book_id, user_id)
    validate_book_availability!(book_id)
    validate_user_borrowed_book!(user_id, book_id)
  end
end
