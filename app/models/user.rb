class User < ApplicationRecord
  has_secure_password
  has_one :entity, as: :entity
  has_one :wallet, through: :entity
  validates :email, uniqueness: true

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true
end
