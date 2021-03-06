class PriceDataService
    THRESHOLD = 0.005

    def initialize(coin)
        @coin = coin
        @price_data = KrakenClient.new(coin).fetch_candles_last_60_min
    end

    def should_buy?
        diff =  ((vwap - close) / close).round(4) 
        puts "Ratio for #{coin}: #{diff}"
        diff > THRESHOLD
    end

    def close 
        price_data[4].to_f
    end

    def vwap 
        price_data[5].to_f
    end

    private

    attr_reader :price_data, :coin
end