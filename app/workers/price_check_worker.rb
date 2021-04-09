class PriceCheckWorker
  COIN_CODES = ["BTC", "ETH", "LTC"]

  def perform
      OrderPruner.new.execute
      
      COIN_CODES.each do |coin|
        OrderService.new(coin).create_order
      end
  end
end
