class Entity < ApplicationRecord
  belongs_to :entity, polymorphic: true
end
