class StockSerializer < ActiveModel::Serializer
  attributes :id, :ticker_symbol, :price

  private
  def price
    object.price.to_f
  end
end
