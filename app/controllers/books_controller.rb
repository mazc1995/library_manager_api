class BooksController < ApplicationController

  def index
    # List all books with model filters
    # return all books that match the filters
    @books = BooksService.new.list_books(index_params)
    render json: @books, status: :ok
  end

  private

  def index_params
    params.permit(:title, :author, :genre, :isbn, :copies, :available).to_h.compact_blank
  end
end
