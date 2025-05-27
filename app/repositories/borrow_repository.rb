class BorrowRepository
  def list_borrows(borrow_params)
    Borrow.where(borrow_params)
  end

  def show_borrow(borrow_params)
    Borrow.find_by(borrow_params)
  end

  def create_borrow(borrow_params)
    Borrow.create!(borrow_params)
  end

  def update_borrow(id, borrow_params)
    Borrow.find(id).update!(borrow_params)
  end

  def destroy_borrow(id)
    Borrow.find(id).destroy!
  end
end