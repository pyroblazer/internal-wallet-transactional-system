module StockPriceClient
  extend ActiveSupport::Concern

  included do
    before_action :initialize_stock_price_client
  end

  private
  def initialize_stock_price_client
    @stock_price_client = LatestStockPrice::Client.new(Rails.application.credentials.dig(:rapid, :api_key))
  end
end
