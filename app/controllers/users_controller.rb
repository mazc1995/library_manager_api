class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_librarian!, only: [:index]
  before_action :set_user, only: [:show]

  def index
    @users = UsersService.new.list_users
    render json: @users, status: :ok
  end

  def show
    user_with_borrows = UsersService.new.user_with_borrows(params[:id])
    render json: user_with_borrows, status: :ok
  end

  private

  def set_user
    @user = UsersService.new.show_user(params[:id])
  end
end 