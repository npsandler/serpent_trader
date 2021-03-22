class PriceCheckWorker
  include ::Sidekiq::Worker

  COIN_CODES = ["BTC", "ETH", "LTC"]

  def perform
      COIN_CODES.each do |coin|
        PriceCheckService.new(coin).execute
      end
  end
end
