desc "This task is called by the Heroku scheduler add-on"
task :check_prices => :environment do
    puts "Begining price check"
    PriceCheckWorker.new.perform
    puts "done."
end

task :statbot => :environment do
    puts "Begining statbot"
    Statbot::StatbotWorker.run
    puts "done."
end