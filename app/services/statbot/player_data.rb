module Statbot
    class PlayerData
        def initialize(name)    
            @name = name
            @games_played = 0
            @kills = 0 
            @knocks = 0 
            @assists = 0
            @damage = 0 
            @best_damage = 0
            @deaths = 0 
            @chicken_dinners = 0
            @longest_kill = 0
            @revives = 0
            @team_kills = 0
            @splatters = 0
            @vehicle_destroys = 0
        end

        def add_match_stats(stats)
            # todo fix this self... bs
            self.games_played += 1 
            self.kills += stats["kills"]
            self.knocks += stats["DBNOs"]
            self.damage += stats["damageDealt"]
            self.assists += stats["assists"]
            self.best_damage = stats["damageDealt"] if stats["damageDealt"] > best_damage
            self.deaths += 1 unless stats["deathType"] == "alive"
            self.chicken_dinners +=1 if stats["winPlace"] == 1
            self.longest_kill = stats["longestKill"] if stats["longestKill"] > longest_kill
            self.revives += stats["revives"]
            self.team_kills += stats["teamKills"]
            self.splatters += stats["roadKills"]
            self.vehicle_destroys += stats["vehicleDestroys"]
        end

        def kd_ratio
            return 0 if self.deaths.zero?
            @kd ||= (self.kills.to_f / self.deaths.to_f).round(3)
        end

        def formatted_for_sms
            return nil if self.games_played.zero?
            entries = ["#{self.name.upcase}"]
            entries <<  "#{self.calc_dinners}" if self.chicken_dinners > 0
            entries << [
                "K/D: #{self.kd_ratio}",
                "Total Kills: #{self.kills}",
                "Assists: #{self.assists}",
                "Average Damage: #{self.avg_damage}",
                "Highest Damage: #{self.best_damage.to_i}"
            ]
            
            entries << "Revives: #{self.revives}" if self.revives > 0
            entries << "Longest Kill: #{self.longest_kill.to_i}" if self.longest_kill > 100
            entries << "Team Kills: #{self.team_kills}" if self.team_kills > 0
            entries << "Splatters: #{self.splatters}" if self.splatters > 0
            entries << "Vehicle Destroys: #{self.vehicle_destroys}" if self.vehicle_destroys > 0
            entries.join("\n")
        end

        attr_reader :name
        attr_accessor :games_played

        private 
        
        def calc_dinners
            res = ""
            self.chicken_dinners.times { res << "🍗 " }
            res
        end

        def avg_damage
            return 0 if self.games_played.zero?
            @avg ||= (self.damage / self.games_played).to_i
        end
    
        attr_accessor :kills,
            :knocks,
            :assists,
            :damage,
            :best_damage,
            :deaths,
            :chicken_dinners,
            :longest_kill,
            :revives,
            :team_kills,
            :splatters,
            :vehicle_destroys
    end
end