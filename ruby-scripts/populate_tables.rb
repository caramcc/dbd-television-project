require 'json'
require 'mysql2'

require_relative 'constants.rb'

@available_keys = %w(title country tvrage_id start_date end_date classification genres runtime network
  airtime airday alternate_titles flagged imdb_id languages writers actors plot_summary award_wins
  award_nominations imdb_rating imdb_votes flag)

def load_data
  all_show_data = []
  Dir.entries('output-data').drop(2).each do |file_path|
    File.open(File.join('output-data', file_path), "r") do |f|
      f.each_line do |line|
        begin
          all_show_data.push JSON.parse(line)
        rescue JSON::ParserError => e
          puts line
        end
      end
    end
  end
  all_show_data
end

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)


@client.query("USE #{$db_name}")

# @client.query("DROP TABLE #{@table}")


def process_data(data_array)
  data_array.each do |row|
    unless row["title"].nil? && row["imdb_id"].nil?

      @available_keys.each do |key|
        if row[key].nil?
          row[key] = ''
        end
      end

      row.each do |key, value|
        if value.instance_of?(String)
          row[key] = @client.escape(value)
        # elsif value.instance_of?(Hash) || value.instance_of?(Array)
        #   row[key] = @client.escape(value.to_s)
        end
      end

      begin
        start_date = Date.parse(row["start_date"]).to_s
        end_date = Date.parse(row["end_date"]).to_s
      rescue ArgumentError, TypeError # if invalid dates
        # puts start_date
        # puts end_date
        start_date ||= '1000-01-01'
        end_date ||= '1000-01-01'
      end

      runtime = row["runtime"].to_i
      award_wins = row["award_wins"].to_i
      award_nominations = row["award_nominations"].to_i
      if row["airtime"].nil?
        airtime = ''
        timezone = ''
      else
        airtime = row["airtime"].split(" ")[0]
        timezone = row["airtime"].split(" ").drop(1).join(" ") # gross
      end
      imdb_votes = row["imdb_votes"].sub!(',','').to_i
      imdb_rating = row["imdb_rating"].to_f
      tvrage_id = row["tvrage_id"].to_i

      if row["flagged"]
        flagged = 1
      else
        flagged = 0
      end

      insert_into_shows = "INSERT INTO #{$tv_shows} (show_title, country, start_date, end_date,
        content_rating, classification, runtime, network, airtime, timezone,
        plot_summary, award_nominations,
        award_wins, imdb_rating, imdb_votes, imdb_id, tvrage_id, flagged, flag) VALUES (
        '#{row["title"]}', '#{row["country"]}', '#{start_date}', '#{end_date}',
        '#{row["content_rating"]}', '#{row["classification"]}', '#{runtime}',
        '#{row["network"]}', '#{airtime}', '#{timezone}', '#{row["plot_summary"]}', '#{award_nominations}', '#{award_wins}',
        '#{imdb_rating}', '#{imdb_votes}', '#{row["imdb_id"]}', '#{tvrage_id}', '#{flagged}', 
        '#{row["flag"]}'
        );"
      @client.query(insert_into_shows)

      show_id = 0
      @client.query("SELECT show_id FROM #{$tv_shows} ORDER BY show_id DESC LIMIT 1;").each do |id|
        show_id = id['show_id']
      end

      if row['genres'].instance_of?(Array)
        row['genres'].each do |genre|
          begin
            genre = @client.escape(genre)
            @client.query("INSERT INTO #{$show_genres} (show_id, genre) VALUES (#{show_id}, '#{genre}');")
          rescue TypeError
            genre.each do |key, value|
              puts "#{key} => #{value}"
            end
          end
        end
      end

      if row['languages'].instance_of?(Array)
        row['languages'].each do |language|
          language = @client.escape(language)
          @client.query("INSERT INTO #{$show_languages} (show_id, language) VALUES (#{show_id}, '#{language}');")
        end
      end

      if row['airday'].instance_of?(Array)
        row['airday'].each do |airday|
          airday = @client.escape(airday)
          @client.query("INSERT INTO #{$show_airdays} (show_id, airday) VALUES (#{show_id}, '#{airday}');")
        end
      end

      if row['alternate_titles'].instance_of?(Array)
        row['alternate_titles'].each do |title|
          title = @client.escape(title)
          @client.query("INSERT INTO #{$show_alt_titles} (show_id, alt_title) VALUES (#{show_id}, '#{title}');")
        end
      end

      if row['actors'].instance_of?(Array)
        row['actors'].each do |actor|

          actor = @client.escape(actor)
          actor_id = 0
          @client.query("SELECT actor_id FROM #{$actors} WHERE actor_name LIKE '#{actor}';").each do |actors|
            actor_id = actors['actor_id']
            puts "found #{actor}, id #{actor_id}"
          end

          if actor_id == 0 # (if actor doesn't exist)
            @client.query("INSERT INTO #{$actors} (actor_name) VALUES ('#{actor}')")
            puts "inserting #{actor}"

            @client.query("SELECT actor_id FROM #{$actors} ORDER BY actor_id DESC LIMIT 1;").each do |id|
              actor_id = id['actor_id']
            end

          end

          # map
          @client.query("INSERT INTO #{$show_actors} (show_id, actor_id) VALUES (#{show_id}, #{actor_id});")
        end
      end


      if row['writers'].instance_of?(Array)
        row['writers'].each do |creator|

          creator = @client.escape(creator)

          creator_id = 0
          @client.query("SELECT creator_id FROM #{$creators} WHERE creator_name LIKE '#{creator}';").each do |creators|
            creator_id = creators['creator_id']
          end

          if creator_id == 0 # (if actor doesn't exist)
            @client.query("INSERT INTO #{$creators} (creator_name) VALUES ('#{creator}')")

            @client.query("SELECT creator_id FROM #{$actors} ORDER BY creator_id DESC LIMIT 1;").each do |id|
              creator_id = id['creator_id']
            end

          end

          # map
          @client.query("INSERT INTO #{$show_creators} (show_id, creator_id) VALUES (#{show_id}, #{creator_id});")
        end
      end


    end
  end
end

process_data(load_data)

