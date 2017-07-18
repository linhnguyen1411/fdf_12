class EventSerializer < ActiveModel::Serializer
  attributes :id, :message, :eventable_type, :eventable_id, :eventitem_id, :read,
    :user_id, :created_at, :updated_at

  def message
    object.load_message
  end
end
