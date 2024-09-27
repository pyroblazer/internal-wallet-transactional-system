class WalletsController < ApplicationController
  before_action :authorized
  before_action :set_walletable
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    wallet = Wallet.find_by(walletable: @walletable.entity)
    render json: { wallet: WalletSerializer.new(wallet) }, status: :ok
  end

  def deposit
    wallet = Wallet.find_by(walletable: @walletable.entity)
    amount = params[:amount].to_d

    if amount <= 0
      return render json: { error: "Deposit amount must be greater than 0" }, status: :unprocessable_entity
    end

    transaction = Transaction.create!(
      sender_wallet: wallet,
      receiver_wallet: wallet,
      amount: amount,
      transaction_type: :credit
    )
    render json: {
      message: "Deposited #{amount} successfully",
      data: {
        wallet_balance: wallet.reload.balance,
        transaction: transaction
      }
    }, status: :ok
  end

  def transfer
    sender_wallet = Wallet.find_by(walletable: @walletable.entity)
    receiver_wallet = receiver_wallet(params[:receiver_wallet_id])
    amount = params[:amount].to_d

    if amount <= 0
      return render json: { error: "Transfer amount must be greater than 0" }, status: :unprocessable_entity
    end

    transaction = Transaction.create!(
      sender_wallet: sender_wallet,
      receiver_wallet: receiver_wallet,
      amount: amount,
      transaction_type: :debit
    )
    Transaction.create!(
      sender_wallet: sender_wallet,
      receiver_wallet: receiver_wallet,
      amount: amount,
      transaction_type: :credit
    )
    render json: {
      message: "Transferred #{amount} successfully",
      data: {
        wallet_balance: sender_wallet.reload.balance,
        transaction: transaction
      }
    }, status: :ok
  end

  private

  def set_walletable
    if params[:user_id]
      @walletable = User.find(params[:user_id])
      authorize_access(@walletable.id)
    elsif params[:team_id]
      @walletable = Team.find(params[:team_id])
      authorize_access(@walletable.team_lead)
    end
  end

  def receiver_wallet(receiver_wallet_id)
    Wallet.find(receiver_wallet_id)
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
