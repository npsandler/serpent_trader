class OrderService
    PHONE_NUMBER = Rails.application.credentials.phone_numbers[:sliptide12]
    LOSS_LIMIT_PERCENT = 0.01
    TAKE_PROFIT_PERCENT = 0.02
    # TODO this is duped in kraken client
     ASSET_PAIRS = {
        "BTC" => "XBTUSDT",
        "ETH" => "ETHUSDT",
        "LTC" => "LTCUSDT",
    }

    def initialize(coin)
        @coin = coin 
        @price_data = PriceDataService.new(coin)
    end

    def create_order
        if price_data.should_buy?
            puts "initiating order for #{coin}"
            place_external_order
            place_stop_loss
            place_take_profit
            record_order
            send_creation_success_sms 
        else 
            puts "Not purchasing #{coin}. No surge detected"
        end
    end

    private

    attr_reader :coin, :price_data

    def place_external_order
        @dollar_amount = client.wallet_usd / 100
        @volume = (@dollar_amount / last_price).round(4)
        puts "Purchase order:"
        @order_id = client.place_order(@volume)   
        puts @order_id 
        @order_id
    end

    def place_stop_loss
        price = last_price - (last_price * LOSS_LIMIT_PERCENT)
        @stop_loss_price = price.round(1)
        puts "Trailing stop order:"
        @stop_loss_order_id = client.set_stop_loss(@stop_loss_price, @volume)
        puts @stop_loss_order_id 
        @stop_loss_order_id
    end

    def place_take_profit
        price = last_price + (last_price * TAKE_PROFIT_PERCENT)
        @take_profit_price = price.round(1)
        puts "Take profit order:"
        @take_profit_order_id =  client.set_take_profit(@take_profit_price, @volume)
        puts @take_profit_order_id 
        @take_profit_order_id
    end

    def last_price
        price_data.close
    end

    def record_order
        Order.new(
            coin_type: coin,
            purchase_price: last_price,
            coin_volume: @volume,
            take_profit: @take_profit_price,
            stop_loss: @stop_loss_price,
            external_order_id: @order_id,
            loss_limit_order_id: @stop_loss_order_id ,
            take_profit_order_id: @take_profit_order_id
        ).save!
    end

    def send_creation_success_sms
        msg = [
            "Creating #{coin} order: ",
            "$#{@dollar_amount} worth at #{last_price}",
            "Stop loss: #{@stop_loss_price}",
            "Take profit: #{@take_profit_price}",
        ].join("\n")

        TwilioTextMessenger.new(msg, PHONE_NUMBER).send
    end

    def client 
        @client ||= KrakenClient.new(coin)
    end
end