class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  attr_reader :current_user

  private

  def authenticate_user!
    auth_header = request.headers['Authorization']
    token = auth_header.to_s.split(' ').last

    @current_user = User.find_by(auth_token: token)
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end
