module Statbot 
    class StatbotWorker
        class << self
            PLAYERS = ["sliptide12", "teebascreeb", "Johnjohnb4", "VON STONKS", "StK MAVRIK"]
            GAME_MODES = ["solo", "duo", "squad"]

            def run 
                GAME_MODES.each do |game_mode|
                    player_stats = []

                    PLAYERS.each do |player|
                        player_stats.push(Statbot::PlayerDataFactory.new(player, game_mode).generate)
                    end

                    send_texts(player_stats, game_mode)
                end                
            end

            private 
            
            def send_texts(player_stats, game_mode)
                stats  = player_stats.sort { |pd| -(pd.kd_ratio) }
                return if stats.all? { |pd| pd.games_played.zero? }

                msg = "🦍 Statbot Report 🦍 \n"
                msg << "🦍  #{game_mode.capitalize()}s 🦍 \n \n"
                mapped_stats =  stats.map { |pd| pd.formatted_for_sms }.compact.join("\n\n") 
                return if mapped_stats.nil?
                
                msg << mapped_stats
                msg << "\n \n 🦍🦍"

                stats.each do |player_data|
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
                    stkmavrik:  Rails.application.credentials.phone_numbers[:stkmavrik]
                }

                map[name.downcase.gsub(/\s+/, "").to_sym]
            end
        end
    end
end