class PriceCheckService
    def initialize(coin)  
        puts "initializing PriceCheckService"  
        @coin = coin
    end

    def execute
        puts "PriceCheckService#execute"
        price_data = PriceDataService.new(coin)
        OrderService.new(coin, price_data.percent_change).create_order if true
        # OrderService.new(coin, price_data.percent_change) if price_data.surging?
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