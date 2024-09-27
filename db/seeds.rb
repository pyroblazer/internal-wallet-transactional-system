# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Seed the Stock records
stocks = Stock.create!([
  { ticker_symbol: "AAPL", price: 150.25 },
  { ticker_symbol: "MSFT", price: 305.50 },
  { ticker_symbol: "AMZN", price: 137.80 },
  { ticker_symbol: "TSLA", price: 250.10 },
  { ticker_symbol: "GOOGL", price: 2765.60 }
])

# Create Entity for each Stock (Polymorphic Associations)
stocks.each do |stock|
  stock.create_entity!
end

# Create Wallets associated with each Entity
Wallet.create!([
  { walletable: stocks[0].entity, balance: 10_000.00 },
  { walletable: stocks[1].entity, balance: 20_000.00 },
  { walletable: stocks[2].entity, balance: 15_000.00 },
  { walletable: stocks[3].entity, balance: 25_000.00 },
  { walletable: stocks[4].entity, balance: 50_000.00 }
])
