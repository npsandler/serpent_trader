class PriceDataService
    CHANGE_THRESHOLD = 0.0275

    def initialize(coin)
        @coin = coin
        @price_data = CoinbaseClient.new(coin).fetch_candles_last_15_min
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
        # each candle entry: [ time, low, high, open, close, volume ]
        @high ||= price_data.sort_by { |entry| entry[3] }.last[3]
    end

    def low
        @low ||= price_data.sort_by { |entry| entry[2] }.first[2]
    end
end