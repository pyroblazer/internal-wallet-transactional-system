class Team < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: :owner_id, required: true
  has_one :entity, as: :entity, dependent: :destroy
  has_one :wallet, through: :entity

  validates_presence_of :name, :size
end
