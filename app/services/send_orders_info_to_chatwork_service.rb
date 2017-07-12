class SendOrdersInfoToChatworkService
  def initialize orders
    @orders = orders
    @room_id = Settings.forder_chatwork_room
  end

  def send
    ChatWork::Message.create room_id: @room_id, body: message_body if to_users.present? 
  end

  private

  def to_users
    to_all = ""
    members = ChatWork::Member.get room_id: @room_id
    @orders.each do |order|
      if !order.is_paid && order.order_products.done.present?
        to_account_id = members
          .find {|member| member["name"] == I18n.transliterate(order.user_name)}
        to = to_account_id.present? ? "[To:#{to_account_id["account_id"]}]" : ""
        to_all += to unless to_all.include? to
      end
    end
    to_all
  end

  def message_body
    body = ""    
    Settings.languages.each do |key, value|
      message = I18n.t("chatwork_order_message", locale: value[:type],
        shop: @orders.first.shop_name)
      body += "\n" + message + Settings.diliver_dot
    end
    to_users + "\n" + "[info]" + Settings.forder_chatwork_title + body + "[/info]"
  end
end
