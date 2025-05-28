class DashboardService
  def initialize
    @book_repository = BookRepository.new
    @borrow_repository = BorrowRepository.new
    @user_repository = UserRepository.new
  end

  def librarian_dashboard
    {
      total_books: total_books_count,
      total_borrowed_books: total_borrowed_books_count,
      books_due_today: books_due_today_count,
      members_with_overdue_books: members_with_overdue_books
    }
  end

  def member_dashboard(user)
    {
      borrowed_books: borrowed_books_for_user(user.id),
      overdue_books: overdue_books_for_user(user.id)
    }
  end

  private

  # Librarian dashboard methods
  def total_books_count
    @book_repository.list_books({}).count
  end

  def total_borrowed_books_count
    @borrow_repository.active_borrows.count
  end

  def books_due_today_count
    @borrow_repository.due_today_borrows.count
  end

  def members_with_overdue_books
    overdue_borrows = @borrow_repository.overdue_borrows.includes(:user, :book)

    members_data = {}
    
    overdue_borrows.each do |borrow|
      user_id = borrow.user.id
      
      members_data[user_id] ||= {
        user_id: user_id,
        user_name: borrow.user.name,
        user_email: borrow.user.email,
        overdue_books: []
      }
      
      days_overdue = (Date.current - borrow.due_date.to_date).to_i
      
      members_data[user_id][:overdue_books] << {
        book_id: borrow.book.id,
        book_title: borrow.book.title,
        book_author: borrow.book.author,
        due_date: borrow.due_date,
        days_overdue: days_overdue
      }
    end

    members_data.values
  end

  # Member dashboard methods
  def borrowed_books_for_user(user_id)
    active_borrows = @borrow_repository.user_active_borrows(user_id)
    
    active_borrows.map do |borrow|
      days_until_due = (borrow.due_date.to_date - Date.current).to_i
      is_overdue = days_until_due < 0
      
      {
        borrow_id: borrow.id,
        book_id: borrow.book.id,
        book_title: borrow.book.title,
        book_author: borrow.book.author,
        book_genre: borrow.book.genre,
        borrow_date: borrow.borrow_date,
        due_date: borrow.due_date,
        days_until_due: days_until_due,
        is_overdue: is_overdue
      }
    end
  end

  def overdue_books_for_user(user_id)
    overdue_borrows = @borrow_repository.user_overdue_borrows(user_id)
    
    overdue_borrows.map do |borrow|
      days_overdue = (Date.current - borrow.due_date.to_date).to_i
      
      {
        borrow_id: borrow.id,
        book_id: borrow.book.id,
        book_title: borrow.book.title,
        book_author: borrow.book.author,
        due_date: borrow.due_date,
        days_overdue: days_overdue
      }
    end
  end
end 