class LatestStocksController < ApplicationController
  include StockPriceClient

  before_action :authorized
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def price_all
    all_prices = @stock_price_client.price_all
    render json: all_prices
  end

  private
  def handle_invalid_record(error)
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(error)
    render json: { error: "Latest stock not found" }, status: :not_found
  end
end
