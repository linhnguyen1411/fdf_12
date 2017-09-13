class SendOrdersInfoToChatworkService
  def initialize orders
    @orders = orders
  end

  def send
    @orders.group_by{|o| o.domain}.each do |domain, orders|
      room = domain.room_chatwork
      if room.present? && to_users(room, orders).present?
        ChatWork::Message.create room_id: room, body: message_body(room, orders)
      end
    end
  end

  private

  def to_users room, orders
    to_all = ""
    begin
      members = ChatWork::Member.get room_id: room
      orders.each do |order|
        if !order.is_paid && order.order_products.done.present?  &&
          (!order.user.chatwork_settings.present? ||
          order.user.chatwork_settings[:chatwork_processed] == Settings.serialize_true)
          to_account_id = members
            .find {|member| member["name"] == I18n.transliterate(order.user_name)}
          to = to_account_id.present? ? "[To:#{to_account_id["account_id"]}]" : ""
          to_all += to unless to_all.include? to
        end
      end
    rescue
      to_all = ""
    end
    to_all
  end

  def message_body room, orders
    body = ""
    Settings.languages.each do |key, value|
      message = I18n.t("chatwork_order_message", locale: value[:type],
        shop: @orders.first.shop_name)
      body += "\n" + message + Settings.diliver_dot
    end
    to_users(room, orders) + "[info]" + Settings.forder_chatwork_title + body + "[/info]"
  end
end
