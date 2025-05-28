class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:signup, :login]

  def signup
    user = User.new(user_params)
    if user.save
      render json: { token: user.auth_token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      user.update(auth_token: SecureRandom.hex(16))
      render json: { token: user.auth_token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def logout
    current_user.update(auth_token: nil)
    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role)
  end
end
