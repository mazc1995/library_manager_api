# Library Management API

A Ruby on Rails API for managing a library system with books, users, and borrows.

## Features

- **User Management**: Support for two user roles (Librarian and Member)
- **Authentication**: Token-based authentication system
- **Book Management**: CRUD operations for books (create/read/update/delete)
- **Borrow System**: Track book borrowing and returns
- **Dashboard**: Tailored dashboards for librarians and members
- **Role-based Authorization**: Different permissions for different user roles

## Technical Stack

- Ruby on Rails (API-only mode)
- PostgreSQL database
- RSpec for testing
- Repository pattern for data access

## Setup

### Prerequisites

- Ruby 3.4+
- Rails 7.0+
- PostgreSQL

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd library_api
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Setup the database:
   ```
   rails db:create
   rails db:migrate
   rails db:seed # Optional - adds sample data
   ```

4. Run the server:
   ```
   rails server
   ```

## Testing

Run the test suite:
```
bundle exec rspec
```

## API Documentation

### Authentication

- **Sign up**: `POST /signup`
  ```json
  {
    "name": "User Name",
    "email": "user@example.com",
    "password": "password",
    "role": "member" // or "librarian"
  }
  ```

- **Login**: `POST /login`
  ```json
  {
    "email": "user@example.com",
    "password": "password"
  }
  ```
  Response includes an auth token to be used in subsequent requests.

- **Logout**: `DELETE /logout`
  Requires authentication header.

All authenticated requests must include the token in the header:
```
Authorization: Bearer <token>
```

### Books

- **List all books**: `GET /books`
  - Query parameters: `title`, `author`, `genre`, `isbn`
  - All users can access

- **Get book details**: `GET /books/:id`
  - All users can access

- **Create book**: `POST /books`
  - Librarians only
  ```json
  {
    "title": "Book Title",
    "author": "Author Name",
    "genre": "Fiction",
    "isbn": "1234567890",
    "copies": 5,
    "available": true
  }
  ```

- **Update book**: `PUT /books/:id`
  - Librarians only

- **Delete book**: `DELETE /books/:id`
  - Librarians only

### Borrows

- **List all borrows**: `GET /borrows`
  - All authenticated users

- **Get borrow details**: `GET /borrows/:id`
  - All authenticated users

- **Create borrow**: `POST /borrows`
  - Members only
  ```json
  {
    "book_id": 1,
    "user_id": 1,
    "borrow_date": "2023-05-01",
    "due_date": "2023-05-15"
  }
  ```

- **Update borrow**: `PUT /borrows/:id`
  - Librarians only

- **Delete borrow**: `DELETE /borrows/:id`
  - Librarians only

### Dashboard

- **Get dashboard data**: `GET /dashboard`
  - Returns different data based on user role

#### Librarian Dashboard
```json
{
  "total_books": 100,
  "total_borrowed_books": 25,
  "books_due_today": 3,
  "members_with_overdue_books": [
    {
      "user_id": 1,
      "user_name": "Member Name",
      "user_email": "member@example.com",
      "overdue_books": [
        {
          "book_id": 1,
          "book_title": "Overdue Book",
          "book_author": "Author Name",
          "due_date": "2023-05-01",
          "days_overdue": 10
        }
      ]
    }
  ]
}
```

#### Member Dashboard
```json
{
  "borrowed_books": [
    {
      "borrow_id": 1,
      "book_id": 1,
      "book_title": "Borrowed Book",
      "book_author": "Author Name",
      "borrow_date": "2023-05-01",
      "due_date": "2023-05-15",
      "days_until_due": 5,
      "is_overdue": false
    }
  ],
  "overdue_books": []
}
```

## Project Structure

- **Models**: `app/models/`
  - `user.rb`: User model with roles (member, librarian)
  - `book.rb`: Book information
  - `borrow.rb`: Tracks book borrowing

- **Controllers**: `app/controllers/`
  - `books_controller.rb`: Book CRUD operations
  - `borrows_controller.rb`: Borrow management
  - `auth_controller.rb`: Authentication
  - `dashboard_controller.rb`: Dashboard data

- **Repositories**: `app/repositories/`
  - Implements repository pattern for data access
  - Separates database queries from business logic

- **Services**: `app/services/`
  - Implements business logic
  - `dashboard_service.rb`: Dashboard data processing

