class SendShopStatusToChatworkService
  def initialize shop
    @shop = shop
    @room_id = Settings.forder_chatwork_room
  end

  def send
    ChatWork::Message.create room_id: @room_id, body: message_body if to_users.present?
  end

  private

  def message_body
    body = ""
    Settings.languages.each do |key, value|
      message = 
        if @shop.off?
          I18n.t("chatwork_shop_message.close",
            locale: value[:type], owner: @shop.owner_name, shop: @shop.name)
        elsif @shop.openforever?
          I18n.t("chatwork_shop_message.open_forever",
            locale: value[:type], owner: @shop.owner_name, shop: @shop.name,
            url: Settings.root_path + Rails.application.routes.url_helpers.shop_path(@shop))
        else
          time = @shop.time_auto_close
          I18n.t("chatwork_shop_message.open",
            locale: value[:type], owner: @shop.owner_name, shop: @shop.name,
            url: Settings.root_path + Rails.application.routes.url_helpers.shop_path(@shop),
            hour: time.hour, min: time.min)
        end
      body += "\n" + message + Settings.diliver_dot
      end
    to_users + "\n" + "[info]" + Settings.forder_chatwork_title + body + "[/info]"
  end

  def to_users
    to_all = ""
    members = ChatWork::Member.get room_id: @room_id
    @shop.followers.each do |user|
      to_account_id = members
        .find {|member| member["name"] == I18n.transliterate(user.name)}
      to_all += "[To:#{to_account_id["account_id"]}]" if to_account_id.present?
    end
    to_all
  end
end
