class UsersController < ApplicationController
  skip_before_action :authorized, only: [ :create ]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def create
    user = User.create!(user_params)
    user.create_entity
    @token = encode_token(user_id: user.id)
    render json: {
      user: UserSerializer.new(user),
      token: @token
    }, status: :created
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end

  def handle_record_invalid(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(error)
    render json: { error: "User not found" }, status: :not_found
  end
end
