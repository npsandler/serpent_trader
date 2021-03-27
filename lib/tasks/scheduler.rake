desc "This task is called by the Heroku scheduler add-on"
task :check_prices => :environment do
    puts "Begining price check"
    PriceCheckWorker.new.perform
    puts "done."
end
