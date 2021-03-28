module Statbot
    class PlayerDataFactory
        def initialize(name)
            @player_name = name
            @player_data = Statbot::PlayerData.new(name)
        end

        def generate
            match_ids = get_match_ids
            return player_data if match_ids.nil? || match_ids.empty?
            match_stats = fetch_all_match_stats(match_ids)
            match_stats.each { |match| add_stats(match) }
            player_data
        end

        private

        attr_reader :player_name, :player_data

        def get_match_ids
            player_param = "players?filter[playerNames]=#{player_name}"
            response = get("#{base_url}#{shard}#{player_param}")
            if response["data"].nil?
                puts "ERROR -- no response from server fetching for #{player_name}" 
                return
            end
            matches = response["data"].first["relationships"]["matches"]["data"]
            puts "Fetched #{matches.count} total matches for #{player_name}"
            matches.map { |match| match["id"] }.uniq
        end

        def fetch_all_match_stats(ids)
            stats = []
            ids.each { |id| stats << match_stats(id)}
            stats = stats.compact
            puts "Filtered #{stats.count} recent matches for #{player_name}"
            stats
        end

        def match_stats(id)
            match = get("#{base_url}#{shard}matches/#{id}")
            return unless within_time_window(match)
            match = match["included"].select { |i| i["type"] == "participant"}.filter do |p|
                player_name == (p["attributes"]["stats"]["name"])
            end
        end 

        def within_time_window(m)
            return false if m.nil?
            match_start = DateTime.parse(m["data"]["attributes"]["createdAt"])
            window_start = (Time.now.change(hour: 11) - 1.day).to_datetime
            match_start > window_start
        end

        def get(request_path="")
            response = HTTParty.get(
                request_path,
                headers: headers
            )

            JSON.parse(response.body)
        end

        def add_stats(match)
            match.each do |player| 
                stats =  player["attributes"]["stats"]
                player_data.add_match_stats(stats)
            end
        end

        def headers
            {
                Authorization: "Bearer #{Rails.application.credentials.pubg[:key]}",
                Accept: "application/vnd.api+json"
            }
        end

        def base_url
            "https://api.pubg.com/"
        end

        def shard 
            "shards/xbox/"
        end
    end
end