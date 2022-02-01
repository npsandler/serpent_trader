module Statbot
    class PlayerDataFactory
        def initialize(name, game_mode)
            @player_name = name
            @game_mode = game_mode
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

        attr_reader :player_name, :player_data, :game_mode

        def get_match_ids
            player_param = "players?filter[playerNames]=#{player_name}"
            response = Rails.cache.fetch("#{player_name}", expires_in: 2.hours) do
                puts("fetching stats for #{player_name}, should only trigger once")
                get("#{base_url}#{shard}#{player_param}")
            end
            if response["data"].nil?
                puts "ERROR -- no response from server fetching for #{player_name}" 
                return
            end
            matches = response["data"].first["relationships"]["matches"]["data"]
            puts "Fetched #{matches.count} total matches for #{player_name} (#{game_mode})"
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
            match = Rails.cache.fetch("#{id}", expires_in: 2.hours) do
                puts("fetching stats for game id: #{id}")
                get("#{base_url}#{shard}matches/#{id}")
            end

            return unless within_time_window(match)
            return unless correct_game_mode(match)

            matchType = get_match_type(match)

            match = match["included"].select { |i| i["type"] == "participant"}.filter do |p|
                player_name == (p["attributes"]["stats"]["name"])
            end

            # append matchType for use by add_match_stats
            match["matchType"] = matchType
        end 

        def within_time_window(m)
            return false if m.nil? || m["errors"].present?

            match_start = DateTime.parse(m["data"]["attributes"]["createdAt"])
            # 11am by heroku time
            window_start = (Time.now.change(hour: 16) - 1.day).to_datetime 
            match_start > window_start
        end

        def correct_game_mode(m)
            m["data"]["attributes"]["gameMode"] == game_mode
        end

        def get_match_type(m) 
            m["data"]["attributes"]["matchType"]
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