class CoinbaseClient
    CHANGE_THRESHOLD = 0.0275
    GRANULARITY = 900

    def initialize(coin=nil)
        @coin = coin
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
        request_path = "/products"
        candles = get(request_path)
    end

    def fetch_candles_last_15_min
        #todo check ECT, LTC here
        product_id = "#{coin}-USD"
        request_path = "/products/#{product_id}/candles"
        time_start = (Time.now - 15.minutes)
        query = {
            start: time_start.iso8601,
            end: Time.now.iso8601,
            granularity: GRANULARITY
        }

        candles = get(request_path, query)
        candles.select { |candle| candle.first > time_start.to_i}
    end

    def wallet_id
        wallet.id
    end

    def wallet_balance
        wallet.balance
    end

    def wallet
        request_path = "/accounts"
        all_wallets = get(request_path)
        # all_wallets.select { |wallet| wallet["currency"] == coin }.first
    end

    # private 

    attr_reader :coin, :cec

    def get(request_path, params="")
        response = HTTParty.get(
           "https://api-public.sandbox.pro.coinbase.com#{request_path}",
        #   "https://api.pro.coinbase.com#{request_path}",
            headers: headers(request_path, "GET", params),
            params: params
        )

        JSON.parse(response.body)
    end

    def post(request_path, body="")
        response = HTTParty.post(
           "https://api-public.sandbox.pro.coinbase.com#{request_path}",
        #   "https://api.pro.coinbase.com#{request_path}",
            headers: headers(request_path, "POST", body),
            body: body
        )

        JSON.parse(response.body)
    end

    def headers(request_path, method, body)
        timestamp = Time.now.to_i

        { 
            "CB-ACCESS-KEY": Rails.application.credentials.coinbase[:key],
            "CB-ACCESS-SIGN": signature(request_path, body, timestamp, method),
            "CB-ACCESS-PASSPHRASE": Rails.application.credentials.coinbase[:passphrase],
            "CB-ACCESS-TIMESTAMP": timestamp.to_s
        }
    end


    # Adapted from coinbase API docs https://docs.pro.coinbase.com/#signing-a-message
    def signature(request_path, body, timestamp, method)
        body = body.to_json if body.is_a?(Hash)
        timestamp = Time.now.to_i if !timestamp

        what = "#{timestamp}#{method}#{request_path}#{body}";

        # create a sha256 hmac with the secret
        secret = Base64.decode64(Rails.application.credentials.coinbase[:secret])
        # secret = Rails.application.credentials.coinbase[:secret]
        binding.pry
        hash  = OpenSSL::HMAC.digest('sha256', secret, what)
        Base64.strict_encode64(hash)
    end
end

