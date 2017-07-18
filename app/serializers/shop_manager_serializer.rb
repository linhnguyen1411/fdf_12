class ShopManagerSerializer < ActiveModel::Serializer
  attributes :id, :role
  belongs_to :user
end
