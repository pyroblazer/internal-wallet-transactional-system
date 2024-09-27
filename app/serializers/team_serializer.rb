class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_id, :size
end
