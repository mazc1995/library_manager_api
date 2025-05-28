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