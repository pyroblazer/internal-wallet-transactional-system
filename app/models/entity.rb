class Entity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  has_one :wallet
end
