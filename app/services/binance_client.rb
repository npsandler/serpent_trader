class BinanceClient
    CHANGE_THRESHOLD = 0.0275
    GRANULARITY = 900

    def initialize(coin=nil)
        @symbol = "#{coin}USDT"
        Binance::Api::Configuration.api_key = Rails.application.credentials.binance[:key]
        Binance::Api::Configuration.secret_key = Rails.application.credentials.binance[:secret]
    end

    def place_order(amount_usd)
        request_path = "/orders" 
        # todo add order id?
        body = {
            side: "buy",
            size: amount_usd,
            product_id: "BTC-USD",
        }

        post(request_path, body)
    end

    def products
        # todo currently just for testing
        Binance::Api.exchange_info!
    end

    def fetch_candles_last_15_min
        time_end = DateTime.now.strftime('%Q')
        time_start = (DateTime.now - 15.minutes).strftime('%Q')
        Binance::Api::candlesticks!(
            startTime: time_start,
            endTime: time_end,
            limit: 500, 
            interval: "1m",
            symbol: symbol
        )
    end

    def wallet_balance
        #todo update to Binance
        wallet.balance
    end

    def ping
        Binance::Api.ping! # => {}
    end

    # private 

    attr_reader :symbol
end

