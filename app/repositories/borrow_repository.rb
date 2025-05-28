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
  
  def active_borrows
    Borrow.where(returned: false)
  end
  
  def overdue_borrows
    active_borrows.where('due_date < ?', Date.current)
  end
  
  def due_today_borrows
    active_borrows.where(due_date: Date.current.beginning_of_day..Date.current.end_of_day)
  end
  
  def user_active_borrows(user_id)
    active_borrows.where(user_id: user_id).includes(:book)
  end
  
  def user_overdue_borrows(user_id)
    overdue_borrows.where(user_id: user_id).includes(:book)
  end
end