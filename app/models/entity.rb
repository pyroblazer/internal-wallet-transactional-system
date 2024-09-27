class Entity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  has_one :wallet, as: :walletable, dependent: :destroy
end
