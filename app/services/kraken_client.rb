class KrakenClient
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
        kclient.add_order(pair: pair, type: 'buy', ordertype: 'market', volume: volume)["result"]["txid"].first
    end

    def set_stop_loss(price, volume)
        # {"error"=>[], "result"=>{"descr"=>{"order"=>"sell 0.00030000 XBTUSDT @ stop loss 57857.9"}, "txid"=>["ODV2IJ-WXRUE-UU5QUS"]}}
        kclient.add_order(
            pair: pair,
            type: 'sell',
            ordertype: 'stop-loss',
            price: price, 
            volume: volume
        )["result"]["txid"].first
    end

    def set_take_profit(price, volume)
        kclient.add_order(
            pair: pair,
            type: 'sell',
            ordertype: 'take-profit',
            price: price, 
            volume: volume
        )["result"]["txid"].first
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

    def open_order_ids
        kclient.open_orders["result"]["open"].keys
    end

    def close_order(id)
        kclient.cancel_order(id)
    end

    attr_reader :coin
    
    private 

    def pair 
        ASSET_PAIRS[coin]
    end

    attr_reader :symbol, :kclient
end

