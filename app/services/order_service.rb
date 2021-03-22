class OrderService
    def initialize(coin, percent_change)
        @coin = coin 
        @percent_change = percent_change
    end

    def create_order
        send_creation_start_sms
        # place_external_order
        # record_order
        # send_creation_success_sms 
    end

    private

    attr_reader :coin, :percent_change

    def send_creation_start_sms
        #todo move number to better place for constants
        number = "+15188176077"
        messages = [
            "#{coin} surged #{formatted_percent_change} in past 15 minutes.",
            "Attempting to place order for #{formatted_purchase_amount}"
        ]
        message = messages.join("\n")

        TwilioTextMessenger.new(message, number).send
    end

    #todo what params are worth texting here
    def send_creation_success_sms
        #todo move number to better place for constants
        number = "+15188176077"
        messages = [
            "Successully placed order for #BTC",
            "Details..."
        ]
        message = messages.join("\n")

        TwilioTextMessenger.new(message, number).send
    end

    def formatted_percent_change
        "#{(percent_change * 100).round(3)}%"
    end

    def formatted_purchase_amount
        #todo replace
        purchase_amount = 2000.to_f
        "$#{purchase_amount / 100}"
    end

    def place_external_order
        # todo implement
        # fetch wallet size
        # purchase 1%
    end

    def record_order
        #todo implement
    end

    def send_creation_success_sms
        #todo implement
    end
end