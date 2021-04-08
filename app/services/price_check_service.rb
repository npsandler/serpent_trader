class PriceCheckService
    def initialize(coin)    
        @coin = coin
    end

    def execute
        #if order exists maybe do something diff
        price_data = PriceDataService.new(coin)
        OrderService.new(coin, price_data.close).create_order if price_data.should_buy?
        # orders = Orders.open(coin)
        # OrderUpdater.new(orders, coin, high, low)
        # fetch data
        # fetch orders
        #compare each
        # do something
    end

    private 

    attr_reader :coin
end