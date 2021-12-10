module Statbot 
    class StatbotWorker
        class << self
            PLAYERS = ["sliptide12", "teebascreeb", "Johnjohnb4", "BEST FAQ", "StK MAVRIK"]
            GAME_MODES = ["solo", "duo", "squad"]

            def run 
                msg = "🦍 Statbot Report 🦍 \n \n"
                any_games_played = false

                GAME_MODES.each do |game_mode|
                    player_stats = []

                    PLAYERS.each do |player|
                        player_stats.push(Statbot::PlayerDataFactory.new(player, game_mode).generate)
                    end

                    next if player_stats.all? { |pd| pd.games_played.zero? }

                    any_games_played = true 

                    msg << "🦍🦍  #{game_mode.capitalize()}s 🦍🦍 \n \n"
                    mapped_stats =  player_stats.map { |pd| pd.formatted_for_sms }.compact.join("\n\n") 
                    msg << mapped_stats
                    msg << "\n \n"
                end    

                msg << "🦍🦍🦍🦍"
                send_texts(msg) if any_games_played
            end

            private 
            
            def send_texts(msg)
                PLAYERS.each do |name|
                    puts "sending text to #{name}"
                    TwilioTextMessenger.new(
                        msg, 
                        phone_map(name)
                    ).send
                end
            end

            def phone_map(name)
                map = { 
                    sliptide12:  Rails.application.credentials.phone_numbers[:sliptide12],
                    teebascreeb:  Rails.application.credentials.phone_numbers[:teebascreeb],
                    johnjohnb4:  Rails.application.credentials.phone_numbers[:johnjohnb4],
                    bestfaq:  Rails.application.credentials.phone_numbers[:bestfaq],
                    stkmavrik:  Rails.application.credentials.phone_numbers[:stkmavrik]
                }

                map[name.downcase.gsub(/\s+/, "").to_sym]
            end
        end
    end
end