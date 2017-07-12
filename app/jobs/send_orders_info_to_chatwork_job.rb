class SendOrdersInfoToChatworkJob < ApplicationJob
  queue_as :default
  
  def perform orders
    SendOrdersInfoToChatworkService.new(orders).send
  end
end
