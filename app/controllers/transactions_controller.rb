class TransactionsController < ApplicationController
  before_action :authorized
  before_action :set_transactions
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    wallet = Wallet.find_by!(walletable: @walletable.entity)
    transactions = Transaction.where(sender_wallet: wallet)
                              .or(Transaction.where(receiver_wallet: wallet))
                              .order(created_at: :desc)

    render json: {
      transactions: ActiveModelSerializers::SerializableResource.new(transactions, each_serializer: TransactionSerializer).as_json
    }, status: :ok
  end

  private
  def set_transactions
    if params[:user_id]
      @walletable = User.find(params[:user_id])
      authorize_access(@walletable.id)
    elsif params[:team_id]
      @walletable = Team.find(params[:team_id])
      authorize_access(@walletable.owner_id)
    end
  end

  def authorize_access(walletable)
    unless walletable == current_user&.id
      render json: { message: "Unauthorized access" }, status: :unauthorized
    end
  end

  def handle_invalid_record(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(error)
    render json: { error: "Wallet not found" }, status: :not_found
  end
end
