class KrakenClient
    CHANGE_THRESHOLD = 0.0275
    GRANULARITY = 900
    ASSET_PAIRS = {
        "BTC" => "XBTUSDT",
        "ETH" => "ETHUSDT",
        "LTC" => "LTCUSDT",
    }

    def initialize(coin=nil)
        @coin = coin
        @symbol = "#{coin}USD"
        @kclient = Kraken::Client.new(
            api_key: Rails.application.credentials.kraken[:key],
            api_secret: Rails.application.credentials.kraken[:secret]
        )
    end

    def place_order(volume)
        pair = ASSET_PAIRS[coin]
        binding.pry
        kclient.add_order(pair: pair, type: 'buy', ordertype: 'market', volume: volume)
    end


    def assets
        kclient.assets
    end

    def fetch_candles_last_15_min
        kclient.ohlc(
            symbol,
            interval: 15,
            since: (Time.now - 15.minutes).to_i
        )["result"].values.first.flatten
    end

    def wallet_usd
        wallet_balance["USDT"].to_f
    end

    def wallet_balance
        kclient.balance["result"]
    end

    # private 

    attr_reader :symbol, :kclient, :coin
end

