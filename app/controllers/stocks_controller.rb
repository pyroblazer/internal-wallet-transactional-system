class StocksController < ApplicationController
  before_action :authorized
  before_action :set_walletable, only: [ :invest, :update_price ]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    stocks = Stock.all
    serialized_stocks = ActiveModelSerializers::SerializableResource.new(stocks, each_serializer: StockSerializer)

    render json: {
      stocks: serialized_stocks.as_json # Convert to JSON before rendering
    }, status: :ok
  end

  def invest
    stock = Stock.find(params[:stock_id])
    amount = params[:amount].to_d

    investor_wallet = Wallet.find_by(walletable: @walletable.entity)
    stock_wallet = Wallet.find_by(walletable: stock.entity)

    if investor_wallet.balance < amount
      return render json: { message: "Insufficient funds available." }, status: :unprocessable_entity
    end

    transaction = create_transaction(investor_wallet, stock_wallet, amount)

    render json: {
      message: "Investment of #{amount} in stock #{stock.ticker_symbol} has been successfully processed.",
      data: {
        wallet_balance: investor_wallet.reload.balance,
        transaction: transaction
      }
    }, status: :ok
  end

  def update_price
    stock = Stock.find(params[:stock_id])
    new_price = params[:new_price].to_d
    old_price = stock.price.to_d

    stock.update!(price: new_price)

    investor_wallet = Wallet.find_by(walletable: @walletable.entity)
    stock_wallet = Wallet.find_by(walletable: stock.entity)

    message = adjust_wallet_for_price_change(stock, old_price, new_price, investor_wallet, stock_wallet)

    render json: {
      message: message,
      data: {
        wallet_balance: investor_wallet.reload.balance,
        stock: StockSerializer.new(stock)
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

  def authorize_access(walletable)
    unless walletable == current_user&.id
      render json: { message: "Access denied: unauthorized user." }, status: :unauthorized
    end
  end

  def create_transaction(sender_wallet, receiver_wallet, amount)
    Transaction.create!(
      sender_wallet: sender_wallet,
      receiver_wallet: receiver_wallet,
      amount: amount,
      transaction_type: :debit
    ).tap do
      Transaction.create!(
        sender_wallet: sender_wallet,
        receiver_wallet: receiver_wallet,
        amount: amount,
        transaction_type: :credit
      )
    end
  end

  def adjust_wallet_for_price_change(stock, old_price, new_price, investor_wallet, stock_wallet)
    invested_amount = stock.amount_invested(investor_wallet, stock_wallet)
        
    if new_price > old_price
      profit = (new_price - old_price) * invested_amount
      create_transaction(stock_wallet, investor_wallet, profit)
      "The stock price has increased, resulting in a profit of #{profit} for the investor."
    else
      loss = (old_price - new_price) * invested_amount
      create_transaction(investor_wallet, stock_wallet, loss)
      "The stock price has decreased, resulting in a loss of #{loss} for the investor."
    end
  end

  def handle_invalid_record(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(error)
    render json: { error: "Stock not found" }, status: :not_found
  end
end
