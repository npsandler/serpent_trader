class PriceCheckWorker
  include ::Sidekiq::Worker
  #todo get other coins working
  # COIN_CODES = ["BTC", "ETH", "LTC"]
  COIN_CODES = ["BTC"]

  def perform
      COIN_CODES.each do |coin|
        PriceCheckService.new(coin).execute
      end
  end
end
