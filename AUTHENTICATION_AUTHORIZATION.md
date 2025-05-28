# Authentication and Authorization in Library API

## Authentication

The Library API uses a custom token-based authentication system. This allows users to log in and access protected resources by providing an authentication token with each request.

### Authentication Flow

1. **User Registration**:
   - Endpoint: `POST /signup`
   - Creates a new user with email, password, name, and role
   - Returns a JWT (JSON Web Token)

2. **User Login**:
   - Endpoint: `POST /login`
   - Verifies credentials and returns a JWT if valid
   - The token contains the user ID and role

3. **Token Usage**:
   - All protected endpoints require the token in the Authorization header
   - Format: `Authorization: Bearer <token>`

4. **Logout**:
   - Endpoint: `DELETE /logout`
   - Invalidates the current token

### Implementation

The authentication system is implemented in the `ApplicationController` with the following methods:

```ruby
def authenticate_user!
  header = request.headers['Authorization']
  if header.blank?
    render json: { error: 'Unauthorized' }, status: :unauthorized
    return
  end

  token = header.split(' ').last
  begin
    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end

def current_user
  @current_user
end
```

## Authorization

The Library API implements a role-based authorization system that restricts access to certain actions based on the user's role.

### User Roles

1. **Librarian**: Can manage books, manage borrows, and view system statistics
2. **Member**: Can view books, borrow books, and view their own borrow history

### Role-Based Access Control

Authorization methods in `ApplicationController`:

```ruby
def authorize_librarian!
  authenticate_user!
  unless current_user&.librarian?
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end

def authorize_member!
  authenticate_user!
  unless current_user&.member?
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end
```

### Permissions by Endpoint

| Endpoint            | Librarian | Member | Unauthenticated |
| ------------------- | --------- | ------ | --------------- |
| GET /books          | ✅         | ✅      | ❌               |
| GET /books/:id      | ✅         | ✅      | ❌               |
| POST /books         | ✅         | ❌      | ❌               |
| PUT /books/:id      | ✅         | ❌      | ❌               |
| DELETE /books/:id   | ✅         | ❌      | ❌               |
| GET /borrows        | ✅         | ✅      | ❌               |
| GET /borrows/:id    | ✅         | ✅      | ❌               |
| POST /borrows       | ❌         | ✅      | ❌               |
| PUT /borrows/:id    | ✅         | ❌      | ❌               |
| DELETE /borrows/:id | ✅         | ❌      | ❌               |
| GET /dashboard      | ✅         | ✅      | ❌               |

### Implementation in Controllers

Authorization is implemented using before_action callbacks in controllers:

```ruby
# BooksController
before_action :authenticate_user!
before_action :authorize_librarian!, only: [:create, :update, :destroy]

# BorrowsController
before_action :authenticate_user!
before_action :authorize_librarian!, only: [:update]
before_action :authorize_member!, only: [:create]

# DashboardController
before_action :authenticate_user!
```

## Dashboard Authorization

The dashboard endpoint (`GET /dashboard`) returns different data based on the user's role:

- **Librarian Dashboard**: Shows system-wide statistics like total books, borrowed books, and members with overdue books
- **Member Dashboard**: Shows only the member's borrowed books and overdue status

This is implemented in the `DashboardController`:

```ruby
class DashboardController < ApplicationController
  def index
    if current_user.librarian?
      render json: DashboardService.new.librarian_dashboard, status: :ok
    elsif current_user.member?
      render json: DashboardService.new.member_dashboard(current_user), status: :ok
    else
      render json: { error: 'Invalid user role' }, status: :forbidden
    end
  end
end
```

## Testing Authentication and Authorization

The application includes comprehensive tests for authentication and authorization:

1. **Auth Helpers**: Helper methods to create authenticated users for testing
2. **Controller Tests**: Each controller has tests to verify authorization rules
3. **Integration Tests**: End-to-end tests to verify complete authentication flow

Example test helper:

```ruby
# spec/support/auth_helpers.rb
module AuthHelpers
  def create_authenticated_member
    user = create(:user, role: :member)
    # generate and return token
    user
  end

  def create_authenticated_librarian
    user = create(:user, role: :librarian)
    # generate and return token
    user
  end

  def auth_headers(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization': "Bearer #{token}" }
  end
end
```

Example authorization test:

```ruby
# spec/requests/books_spec.rb
RSpec.describe "Books", type: :request do
  let(:member) { create_authenticated_member }
  let(:librarian) { create_authenticated_librarian }

  describe "POST /books" do
    it "allows librarians to create books" do
      post "/books", headers: auth_headers(librarian), params: valid_attributes
      expect(response).to have_http_status(:created)
    end

    it "prevents members from creating books" do
      post "/books", headers: auth_headers(member), params: valid_attributes
      expect(response).to have_http_status(:forbidden)
    end
  end
end
``` 