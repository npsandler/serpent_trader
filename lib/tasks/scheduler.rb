desc "This task is called by the Heroku scheduler add-on"
task :check_prices => :environment do
    puts "Begining price check"
    COIN_CODES = ["BTC", "ETH", "LTC"]

    def perform
        COIN_CODES.each do |coin|
            PriceCheckService.new(coin).execute
        end
    end
    puts "done."
end
