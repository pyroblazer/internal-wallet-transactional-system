class User < ApplicationRecord
  has_secure_password
  has_one :entity, as: :entity
  has_one :wallet, through: :entity
  validates :email, uniqueness: true
end
