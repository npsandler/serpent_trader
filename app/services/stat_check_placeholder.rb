class StatCheckPlaceholder
    def initialize
        @player_data_list = player_data
    end

    def execute
        match_ids = get_match_ids
        match_stats = fetch_all_match_stats(match_ids)
        match_stats.each { |match| add_to_players(match) }
        send_texts
    end

    private

    def fetch_all_match_stats(ids)
        stats = []
        ids.each { |id| stats << match_stats(id)}
        stats.compact
    end

    def match_stats(id)
        match = get("#{base_url}#{shard}matches/#{id}")
        return unless within_time_window(match)
        match = match["included"].select { |i| i["type"] == "participant"}.filter do |p|
            player_list.include?(p["attributes"]["stats"]["name"])
        end
    end 

    def within_time_window(m)
        match_start = DateTime.parse(m["data"]["attributes"]["createdAt"])
        window_start = (Time.now.change(hour: 11) - 1.day).to_datetime
        match_start > window_start
    end

    def get_match_ids
        players = "players?filter[playerNames]=#{player_list.join(",")}"
        response = get("#{base_url}#{shard}#{players}")
        matches = response["data"].first["relationships"]["matches"]["data"]
        matches.map { |match| match["id"] }.uniq
    end

    def get(request_path="")
        response = HTTParty.get(
            request_path,
            headers: headers
        )

        JSON.parse(response.body)
    end

    def add_to_players(match)
        match.each do |player| 
            stats =  player["attributes"]["stats"]
            pd = @player_data_list.select { |pd| pd.name == stats["name"] }.first
            pd.add_match_stats(stats)
        end
    end

    def headers
        {
            Authorization: "Bearer #{Rails.application.credentials.pubg[:key]}",
            Accept: "application/vnd.api+json"
        }
    end

    def player_list
        # todo add other players )Dan()
        ["sliptide12", "teebascreeb", "Johnjohnb4"]
    end

    def player_map
        { 
            sliptide12:  Rails.application.credentials.phone_numbers[:sliptide12],
            teebascreeb:  Rails.application.credentials.phone_numbers[:teebascreeb],
            Johnjohnb4:  Rails.application.credentials.phone_numbers[:Johnjohnb4]
        }.with_indifferent_access
    end

    def player_data 
        player_list.map do |name|
            PlayerData.new(name)
        end
    end

    def base_url
        "https://api.pubg.com/"
    end

    def shard 
        "shards/xbox/"
    end

    def send_texts
        pld = @player_data_list.sort { |pd| -(pd.kd_ratio) }
        # why is the first pass always emptry????
        msg = "🦍 Statbot Report 🦍 \n \n"
        mapped_stats =  pld.map { |pd| pd.formatted_for_sms }.compact.join("\n\n") 

        return false if mapped_stats.nil?
        
        msg << mapped_stats
        msg << "\n \n 🦍 End Report 🦍"
        player_list.each do |player|
            next if player_map[player].nil?
            TwilioTextMessenger.new(
                msg, 
                player_map[player]
            ).send
        end
    end
end