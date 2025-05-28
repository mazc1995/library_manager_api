# Repository Pattern in Library API

## Overview

The Library API implements the Repository Pattern to separate data access logic from business logic. This pattern provides several benefits:

1. **Separation of concerns** - Business logic is kept separate from data access code
2. **Improved testability** - Repositories can be mocked for unit testing
3. **Flexibility** - Database implementation can be changed without affecting business logic
4. **Reusability** - Repository methods can be reused across different services

## Implementation

### Structure

The repository classes are located in the `app/repositories` directory:

- `book_repository.rb` - Handles book data access
- `borrow_repository.rb` - Handles borrow data access
- `user_repository.rb` - Handles user data access

### Usage Pattern

1. Each repository encapsulates database operations for a specific model
2. Services use repositories to access data rather than using ActiveRecord directly
3. Controllers call services which in turn use repositories

## Examples

### Book Repository

```ruby
# app/repositories/book_repository.rb
class BookRepository
  def list_books(filters)
    # receive filters of model Book
    # return all books that match the filters
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
    Book.find(id)
  end

  def create_book(book_params)
    Book.create!(book_params)
  end

  def update_book(id, book_params)
    Book.find(id).update!(book_params)
  end

  def destroy_book(id)
    Book.find(id).destroy!
  end
end
```

### Borrow Repository

```ruby
# app/repositories/borrow_repository.rb
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
```

## Service Integration

Services use repositories to access data. This allows services to focus on business logic without being concerned with data access details.

```ruby
# app/services/dashboard_service.rb (example)
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

  private

  def total_books_count
    @book_repository.list_books({}).count
  end

  def total_borrowed_books_count
    @borrow_repository.active_borrows.count
  end

  # ...more methods...
end
```

## Testing

Using the repository pattern makes it easier to test services by allowing you to mock the repositories:

```ruby
# spec/services/dashboard_service_spec.rb (example)
RSpec.describe DashboardService, type: :service do
  let(:book_repository) { instance_double("BookRepository") }
  let(:borrow_repository) { instance_double("BorrowRepository") }
  let(:user_repository) { instance_double("UserRepository") }
  let(:service) { described_class.new }

  before do
    allow(BookRepository).to receive(:new).and_return(book_repository)
    allow(BorrowRepository).to receive(:new).and_return(borrow_repository)
    allow(UserRepository).to receive(:new).and_return(user_repository)
    
    allow(book_repository).to receive(:list_books).and_return([])
    allow(borrow_repository).to receive(:active_borrows).and_return([])
    # ...more mock setups...
  end

  # Test methods
end
```

## Benefits in This Project

1. **Dashboard Feature** - The repository pattern allowed us to create specialized query methods for the dashboard while keeping the service focused on formatting and presenting the data.

2. **Role-based Authorization** - Repositories help keep authorization logic separate from data access, making the code more maintainable.

3. **Testability** - The services are more easily tested in isolation by mocking the repositories. 