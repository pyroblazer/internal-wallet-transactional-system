class Stock < ApplicationRecord
  has_one :entity, as: :entity
  has_one :wallet, through: :entity
end
