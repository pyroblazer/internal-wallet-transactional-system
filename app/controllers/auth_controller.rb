class AuthController < ApplicationController
  skip_before_action :authorized, only: [ :login, :logout ]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_invalid_credentials

  def login
    @user = User.find_by(email: login_params[:email])
    if @user&.authenticate(login_params[:password])
      @token = encode_token(user_id: @user.id)
      render json: {
        user: UserSerializer.new(@user),
        token: @token
      }, status: :accepted
    else
      handle_invalid_credentials
    end
  end

  def logout
    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  def login_params
    params.permit(:email, :password)
  end

  def handle_invalid_credentials
    render json: { message: "Invalid email or password" }, status: :unauthorized
  end
end
