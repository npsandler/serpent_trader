class PriceDataService
    THRESHOLD = 0.005

    def initialize(coin)
        @coin = coin
        @price_data = KrakenClient.new(coin).fetch_candles_last_15_min
    end

    def should_buy?
        puts "Should buy #{coin}?"
        puts "calculated diff: "
        puts (vwap - close) / close
        (vwap - close) / close > THRESHOLD
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