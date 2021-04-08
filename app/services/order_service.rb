class OrderService
    PHONE_NUMBER = Rails.application.credentials.phone_numbers[:sliptide12]

    def initialize(coin, current_price)
        @coin = coin 
        @current_price = current_price 
    end

    def create_order
        send_creation_start_sms
        # place_external_order
        # record_order
        # send_creation_success_sms 
    end

    private

    attr_reader :coin, :current_price

    def send_creation_start_sms
        messages = [
            "Attempting to place order for #{coin}"
        ]
        message = messages.join("\n")

        TwilioTextMessenger.new(message, PHONE_NUMBER).send
    end

    #todo what params are worth texting here
    def send_creation_success_sms
        messages = [
            "Successully placed order for #BTC",
            "Details..."
        ]
        message = messages.join("\n")

        TwilioTextMessenger.new(message, PHONE_NUMBER).send
    end

    def place_external_order
        dollar_amount = client.wallet_usd / 100
        volume = (dollar_amount / current_price).round(4)
        client.place_order(volume)      
    end

    def record_order
        #todo implement
    end

    def send_creation_success_sms
        #todo implement
    end

    def client 
        @client ||= KrakenClient.new(coin)
    end
end