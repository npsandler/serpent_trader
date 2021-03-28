module Statbot 
    class StatbotWorker
        class << self
            PLAYERS = ["sliptide12", "teebascreeb", "Johnjohnb4", "VON STONKS", "StK MAVRICK"]

            def run 
                player_stats = []

                PLAYERS.each do |player|
                    player_stats.push(Statbot::PlayerDataFactory.new(player).generate)
                end
                
                send_texts(player_stats)
            end

            private 
            
            def send_texts(player_stats)
                stats  = player_stats.sort { |pd| -(pd.kd_ratio) }
                msg = "🦍 Statbot Report 🦍 \n \n"
                mapped_stats =  stats.map { |pd| pd.formatted_for_sms }.compact.join("\n\n") 
                puts mapped_stats
                return if mapped_stats.nil?
                
                msg << mapped_stats
                msg << "\n \n 🦍 End Report 🦍"

                stats.each do |player_data|
                    if player_data.games_played.zero?
                        puts "not texting #{player_data.name}, didnt play"
                        next
                    end

                    next if phone_map(player_data.name).nil?
                    puts "sending text to #{player_data.name}"
                    TwilioTextMessenger.new(
                        msg, 
                        phone_map(player_data.name)
                    ).send
                end
            end

            def phone_map(name)
                map = { 
                    sliptide12:  Rails.application.credentials.phone_numbers[:sliptide12],
                    teebascreeb:  Rails.application.credentials.phone_numbers[:teebascreeb],
                    johnjohnb4:  Rails.application.credentials.phone_numbers[:johnjohnb4],
                    vonstonks:  Rails.application.credentials.phone_numbers[:vonstonks],
                    stkmavrick:  Rails.application.credentials.phone_numbers[:stkmavrick]
                }

                map[name.downcase.gsub(/\s+/, "").to_sym]
            end
        end
    end
end