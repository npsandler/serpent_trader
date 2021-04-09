class Order < ApplicationRecord
  # validates :coin_volume, :coin_type, 
  #   :purchase_price, :take_profit,
  #   :stop_loss, :external_order_id, 
  #   :loss_limit_order_id, :take_profit_order_id, presence: true
  # todo look up adding indices
  
  def self.open
    where(is_closed: false).to_a
  end
end
