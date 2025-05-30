class BooksController < ApplicationController
  before_action :set_book, only: [:show, :update, :destroy]
  before_action :authorize_librarian!, only: [:create, :update, :destroy]

  def index
    # List all books with model filters
    # return all books that match the filters
    @books = BooksService.new.list_books(book_params)
    render json: @books, status: :ok
  end

  def show
    # Show a book by id or isbn
    # return the book
    render json: @book, status: :ok
  end

  def create
    # Create a new book
    # return the book
    @book = BooksService.new.create_book(book_params)
    render json: @book, status: :created
  end

  def update
    # Update a book
    # return the book
    @book = BooksService.new.update_book(@book.id, book_params)
    render json: @book, status: :ok
  end

  def destroy
    # Destroy a book
    # return the book
    BooksService.new.destroy_book(@book.id)
    render head: :no_content, status: :ok
  end

  private

  def book_params
    params.permit(:title, :author, :genre, :isbn, :copies, :available).to_h.compact_blank
  end

  def set_book
    @book = BooksService.new.show_book(params[:id])
  end
end
