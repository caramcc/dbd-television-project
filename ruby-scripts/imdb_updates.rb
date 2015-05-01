require 'net/http'
require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

def blank?(object)
  if object.instance_of?(Array) || object.instance_of?(Hash)
    return object.nil? || object.length == 0
  else
    return object.nil? || object.strip == ''
  end
end

# query for all show titles, show ids, and start years where imdb_id does not exist
no_imdb_data_shows = @client.query("SELECT show_title, show_id, start_date FROM #{$tv_shows} WHERE imdb_id LIKE ''")

no_start_years = []
no_series = []
found_ids = []
no_imdb_data_shows.each do |show|
  # search omdb for title like show_title and start_year like start_year
  start_year = show['start_date'].year
  start_year != 1000 ? sy ="&y=#{start_year}" : sy = ''
  omdb_id_url = "http://www.omdbapi.com/?s=#{show['show_title'].gsub(/\W/, '+') }#{sy}&type=series&r=json"
  omdb_id_uri = URI.parse(omdb_id_url)
  omdb_id_response = Net::HTTP.get_response(omdb_id_uri)

  omdb_id_data = JSON.parse(omdb_id_response.body)

  imdb_id = ''
  unless omdb_id_data["Response"] == "False"
    if omdb_id_data["Search"].length < 2
      imdb_id = omdb_id_data["Search"][0]["imdbID"]
    elsif omdb_id_data["Search"].length == 0
      no_start_years.push({show_title: show['show_title'], show_id: show['show_id']})
      puts 'did not find with start year'
    else
      imdb_ids = []
      omdb_id_data["Search"].each do |result|
        imdb_ids.push result["imdbID"]
      end
      imdb_id = imdb_ids[0]
    end
    found_ids.push({imdb_id: imdb_id, show_id: show['show_id']})
    puts 'found with start year'
  end

end


no_start_years.each do |show|
  # search omdb for title like show_title and start_year like start_year
  omdb_id_url = "http://www.omdbapi.com/?s=#{show[:show_title].gsub(/\W/, '+') }&type=series&r=json"
  omdb_id_uri = URI.parse(omdb_id_url)
  omdb_id_response = Net::HTTP.get_response(omdb_id_uri)

  omdb_id_data = JSON.parse(omdb_id_response.body)

  imdb_id = ''
  unless omdb_id_data["Response"] == "False"
    if omdb_id_data["Search"].length < 2
      imdb_id = omdb_id_data["Search"][0]["imdbID"]
    elsif omdb_id_data["Search"].length == 0
      no_series.push({show_title: show[:show_title], show_id: show[:show_id]})
      puts 'did not find without start year'
    else
      imdb_ids = []
      omdb_id_data["Search"].each do |result|
        imdb_ids.push result["imdbID"]
      end
      imdb_id = imdb_ids[0]
    end
    found_ids.push({imdb_id: imdb_id, show_id: show[:show_id]})
    puts 'found without start year!'
  end

end


no_series.each do |show|
  # search omdb for title like show_title and start_year like start_year
  omdb_id_url = "http://www.omdbapi.com/?s=#{show[:show_title].gsub(/\W/, '+') }&r=json"
  omdb_id_uri = URI.parse(omdb_id_url)
  omdb_id_response = Net::HTTP.get_response(omdb_id_uri)

  omdb_id_data = JSON.parse(omdb_id_response.body)

  imdb_id = ''
  unless omdb_id_data["Response"] == "False"
    if omdb_id_data["Search"].length < 2
      imdb_id = omdb_id_data["Search"][0]["imdbID"]
    elsif omdb_id_data["Search"].length == 0
      puts "gave up on #{show[:show_title]}"
    else
      imdb_ids = []
      omdb_id_data["Search"].each do |result|
        imdb_ids.push result["imdbID"]
      end
      imdb_id = imdb_ids[0]
    end
    found_ids.push({imdb_id: imdb_id, show_id: show[:show_id]})
    puts 'found without series'
  end

end


found_ids.each do |show|
  show_id = show[:show_id]

  omdb_show_url = "http://www.omdbapi.com/?i=#{show[:imdb_id]}&plot=full&r=json"
  omdb_show_uri = URI.parse(omdb_show_url)
  omdb_show_response = Net::HTTP.get_response(omdb_show_uri)

  omdb_data = JSON.parse(omdb_show_response.body)

  show_data = {}

  if omdb_data["Response"] == "True"
    show_data['imdb_id'] = show[:imdb_id]

    show_data["languages"] = omdb_data["Language"].split(",").map {|x| x.strip}
    show_data["writers"] = omdb_data["Writer"].split(",").map {|x| x.strip}
    show_data["actors"] = omdb_data["Actors"].split(",").map {|x| x.strip}
    show_data["plot_summary"] = @client.escape(omdb_data["Plot"])
    show_data["content_rating"] = omdb_data["Rated"]


    # add Awards: regex for "X wins & Y nominations."
    # --> award_wins, award_nominations. If N/A, = 0
    # holy nuggets this is gross-looking
    wins = /[0-9]+/.match(/[0-9]+ wins/.match(omdb_data["Awards"]).to_s).to_s
    noms = /[0-9]+/.match(/[0-9]+ nominations/.match(omdb_data["Awards"]).to_s).to_s

    if blank?(wins)
      wins = 0
    end

    if blank?(noms)
      noms = 0
    end

    show_data["award_wins"] = wins
    show_data["award_nominations"] = noms

    show_data["imdb_rating"] = omdb_data["imdbRating"]
    show_data["imdb_votes"] = omdb_data["imdbVotes"]

    show_data["genres"] = (omdb_data["Genre"].split(",").map {|x| x.strip})

    @client.query("UPDATE #{$tv_shows} SET plot_summary='#{show_data['plot_summary']}', content_rating='#{show_data['content_rating']}',
        award_wins='#{show_data['award_wins']}', award_nominations='#{show_data['award_nominations']}', imdb_rating='#{show_data['imdb_rating']}',
        imdb_votes='#{show_data['imdb_votes']}', imdb_id='#{show[:imdb_id]}'
        WHERE show_id='#{show_id}'")

    puts "UPDATE #{$tv_shows} SET plot_summary=#{show_data['plot_summary']}, content_rating=#{show_data['content_rating']},
        award_wins=#{show_data['award_wins']}, award_nominations=#{show_data['award_nominations']}, imdb_rating=#{show_data['imdb_rating']},
        imdb_votes=#{show_data['imdb_votes']}, imdb_id=#{show[:imdb_id]}
        WHERE show_id=#{show_id}"

    if show_data['genres'].instance_of?(Array)
      show_data['genres'].each do |genre|
        begin
          genre = @client.escape(genre)
          @client.query("INSERT INTO #{$show_genres} (show_id, genre) VALUES (#{show_id}, '#{genre}');")
        rescue TypeError, Mysql2::Error
          # do nothing
        end
      end
    end

    if show_data['languages'].instance_of?(Array)
      show_data['languages'].each do |language|
        begin
          language = @client.escape(language)
          @client.query("INSERT INTO #{$show_languages} (show_id, language) VALUES (#{show_id}, '#{language}');")
        rescue Mysql2::Error
          # do nothing
        end
      end
    end

    if show_data['actors'].instance_of?(Array)
      show_data['actors'].each do |actor|

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
        begin
          @client.query("INSERT INTO #{$show_actors} (show_id, actor_id) VALUES (#{show_id}, #{actor_id});")
        rescue Mysql2::Error => e
          puts e
        end

      end
    end


    if show_data['writers'].instance_of?(Array)
      show_data['writers'].each do |creator|

        creator = @client.escape(creator)

        creator_id = 0
        @client.query("SELECT creator_id FROM #{$creators} WHERE creator_name LIKE '#{creator}';").each do |creators|
          creator_id = creators['creator_id']
        end

        if creator_id == 0 # (if actor doesn't exist)
          @client.query("INSERT INTO #{$creators} (creator_name) VALUES ('#{creator}')")

          @client.query("SELECT creator_id FROM #{$creators} ORDER BY creator_id DESC LIMIT 1;").each do |id|
            creator_id = id['creator_id']
          end

        end

        # map
        begin
          @client.query("INSERT INTO #{$show_creators} (show_id, creator_id) VALUES (#{show_id}, #{creator_id});")
        rescue Mysql2::Error => e
          puts e
        end
      end
    end

  else
    puts "(#{show[:imdb_id]}) Bad response from OMDB:"
    puts omdb_data
  end
end

# get omdb data for imdb id = each od the new imdb ids
# update imdb data where show_id is this show id