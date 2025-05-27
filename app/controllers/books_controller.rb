class BooksController < ApplicationController
  before_action :set_book, only: [:show]

  def index
    # List all books with model filters
    # return all books that match the filters
    @books = BooksService.new.list_books(index_params)
    render json: @books, status: :ok
  end

  def show
    # Show a book by id or isbn
    # return the book
    render json: @book, status: :ok
  end

  private

  def index_params
    params.permit(:title, :author, :genre, :isbn, :copies, :available).to_h.compact_blank
  end

  def set_book
    @book = BooksService.new.show_book(params[:id])
  end
end
