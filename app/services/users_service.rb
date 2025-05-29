class UsersService
  def list_users
    UserRepository.new.list_users
  end

  def show_user(id)
    UserRepository.new.show_user(id)
  end

  def user_with_borrows(id)
    user = show_user(id)
    
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      borrows: user.borrows.includes(:book).map do |borrow|
        {
          id: borrow.id,
          book_id: borrow.book.id,
          book_title: borrow.book.title,
          book_author: borrow.book.author,
          book_genre: borrow.book.genre,
          borrow_date: borrow.borrow_date,
          due_date: borrow.due_date,
          returned: borrow.returned,
          returned_date: borrow.returned_date,
          days_until_due: (borrow.due_date.to_date - Date.current).to_i,
          is_overdue: borrow.due_date.to_date < Date.current && !borrow.returned
        }
      end
    }
  end
end 