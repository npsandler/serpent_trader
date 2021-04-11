class OrderPruner
    def execute
        external_order_ids = KrakenClient.new.open_order_ids
        open_order_ids = []

        Order.open.each do |o|
            loss_limit_still_open = external_order_ids.include?(o.loss_limit_order_id)
            take_profit_still_open = external_order_ids.include?(o.take_profit_order_id)
            if loss_limit_still_open && take_profit_still_open
                open_order_ids << o.loss_limit_order_id
                open_order_ids << o.take_profit_order_id
            else
                if !loss_limit_still_open && take_profit_still_open
                    loss =  o.stop_loss - o.purchase_price
                    o.update_column(:profit, loss) 
                elsif !take_profit_still_open && loss_limit_still_open
                    gain = o.take_profit - o.purchase_price
                    o.update_column(:profit, gain) 
                end
                o.update_column(:is_closed, true) 
                o.update_column(:closed_date, Time.now) 
                o.save!
            end
        end

        orders_ids_to_close = external_order_ids - open_order_ids
        puts "Closing the following orders: #{orders_ids_to_close}"
        orders_ids_to_close.each { |id| KrakenClient.new.close_order(id)}
    end

    private 

    attr_reader :coin
end