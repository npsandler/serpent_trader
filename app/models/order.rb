class Order < ApplicationRecord
  validates :is_closed, :cost_cents, :coin_value, :stop_price, presence: true
  # todo validate coin type, order_nmber
  #todo make external order non nullable
  # todo look up adding indices
  
  attr_reader :is_closed, :cost_cents, :coin_value
  attr_accessor :stop_price
  
  def self.open
    where(is_closed: false).to_a
  end
end
