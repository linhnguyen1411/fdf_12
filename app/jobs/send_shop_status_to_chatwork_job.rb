class SendShopStatusToChatworkJob < ApplicationJob
  queue_as :default
  
  def perform shop
    SendShopStatusToChatworkService.new(shop).send
  end
end
