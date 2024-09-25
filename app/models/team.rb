class Team < ApplicationRecord
  has_one :entity, as: :entity, dependent: :destroy
  has_one :wallet, through: :entity
end
