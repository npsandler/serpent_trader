module Statbot
    class PlayerData
        attr_reader :name, :games_played

        def initialize(name)    
            @name = name
            @games_played = 0
            @kills = 0 
            @knocks = 0 
            @assists = 0
            @damage = 0 
            @best_damage = 0
            @deaths = 0 
            @casual_chicken_dinners = 0
            @unranked_chicken_dinners = 0
            @ranked_chicken_dinners = 0
            @longest_kill = 0
            @revives = 0
            @team_kills = 0
            @splatters = 0
            @vehicle_destroys = 0
            @best_finish = 101
        end

        def add_match_stats(stats)
            @games_played += 1 
            @kills += stats["kills"]
            @knocks += stats["DBNOs"]
            @damage += stats["damageDealt"]
            @assists += stats["assists"]
            @best_damage = stats["damageDealt"] if stats["damageDealt"] > @best_damage
            @deaths += 1 unless stats["deathType"] == "alive"
            @best_finish = stats["winPlace"] if stats["winPlace"] < @best_finish
            @longest_kill = stats["longestKill"] if stats["longestKill"] > @longest_kill
            @revives += stats["revives"]
            @team_kills += stats["teamKills"]
            @splatters += stats["roadKills"]
            @vehicle_destroys += stats["vehicleDestroys"]

            # locally scope matchType for conditionals
            matchType = stats["matchType"]
            # casual - 'airoyale'
            @casual_chicken_dinners += 1 if stats["winPlace"] == 1 && matchType == "airoyale"
            # unranked - 'official'
            @unranked_chicken_dinners += 1 if stats["winPlace"] == 1 && matchType == "official"
            # ranked - 'competitive'
            @ranked_chicken_dinners += 1 if stats["winPlace"] == 1 && matchType == "competitive"
        end

        def kd_ratio
            return 0 if @deaths.zero?
            @kd ||= (@kills.to_f / @deaths.to_f).round(3)
        end

        def any_din_dins?
            @casual_chicken_dinners > 0 ||
                @unranked_chicken_dinners > 0 || 
                @ranked_chicken_dinners > 0
        end

        def formatted_for_sms
            return nil if @games_played.zero?
            entries = ["#{name.upcase}"]
            entries <<  "#{calc_dinners}" if any_din_dins?
            entries <<  "Best Finish: #{@best_finish}" if !any_din_dins?
            entries << [
                "K/D: #{kd_ratio}",
                "Total Kills: #{@kills}",
                "Assists: #{@assists}",
                "Average Damage: #{avg_damage}",
                "Highest Damage: #{@best_damage.to_i}",
                "Games Played: #{@games_played.to_i}"
            ]
            
            entries << "Revives: #{@revives}" if @revives > 0
            entries << "Longest Kill: #{@longest_kill.to_i}" if @longest_kill > 100
            entries << "Team Kills: #{@team_kills}" if @team_kills > 0
            entries << "Splatters: #{@splatters}" if @splatters > 0
            entries << "Vehicle Destroys: #{@vehicle_destroys}" if @vehicle_destroys > 0
            entries.join("\n")
        end

        private 
        
        def calc_dinners
            res = ""
            @casual_chicken_dinners.times { res << "🦾 " }
            @unranked_chicken_dinners.times { res << "🍗 " }
            @ranked_chicken_dinners.times { res << "🏆 " }
            res
        end

        def avg_damage
            return 0 if @games_played.zero?
            @avg ||= (@damage / @games_played).to_i
        end
    end
end