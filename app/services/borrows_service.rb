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

  def update_borrow(id)
    # receive id and borrow_params
    # A user is returning a book
    borrow = BorrowRepository.new.show_borrow({id: id})
    book = BookRepository.new.show_book(borrow.book_id)
    run_return_validations!(id)
    ActiveRecord::Base.transaction do
      BookRepository.new.update_book(book.id, { copies: book.copies + 1 })
      BorrowRepository.new.update_borrow(id, { returned: true, returned_date: DateTime.now })
    end
  end

  def destroy_borrow(id)
    # receive id
    # Destroy the borrow
    BorrowRepository.new.destroy_borrow(id)
  end

  private

  def run_borrow_validations!(book_id, user_id)
    validate_book_availability!(book_id)
    validate_user_borrowed_book!(user_id, book_id)
  end

  def run_return_validations!(borrow_id)
    validate_borrow_returned!(borrow_id)
  end
end
