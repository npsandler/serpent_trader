class PriceDataService
    CHANGE_THRESHOLD = 0.02

    def initialize(coin)
        @coin = coin
        @price_data = BinanceClient.new(coin).fetch_candles_last_15_min
    end

    def all
        # todo remove : for testing only
        price_data
    end

    def percent_change
        (high.to_f - low.to_f) / low.to_f
    end

    def surging?
        # verify this
        percent_change > CHANGE_THRESHOLD
    end

    private

    attr_reader :price_data, :coin

     def high
        # based on binance response: 
        # https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#market-data-endpoints
        @high ||= price_data.sort_by { |entry| entry[2] }.last[2]
    end

    def low
        @low ||= price_data.sort_by { |entry| entry[3] }.first[3]
    end
end