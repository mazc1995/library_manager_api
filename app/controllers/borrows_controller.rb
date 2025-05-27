class BorrowsController < ApplicationController
  before_action :set_borrow, only: [:show, :update, :destroy]

  def index
    @borrows = BorrowsService.new.list_borrows(borrow_params)
    render json: @borrows, status: :ok
  end

  def show
    render json: @borrow, status: :ok
  end

  def create
    @borrow = BorrowsService.new.create_borrow(borrow_params)
    render json: @borrow, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    @borrow = BorrowsService.new.update_borrow(params[:id], borrow_params)
    render json: @borrow, status: :ok
  end

  def destroy
    BorrowsService.new.destroy_borrow(@borrow.id)
    head :no_content
  end

  private

  def borrow_params
    params.permit(:user_id, :book_id, :borrow_date, :due_date)
  end

  def set_borrow
    @borrow = BorrowRepository.new.show_borrow({id: params[:id]})
  end
end
