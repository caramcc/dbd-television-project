require 'net/http'
require 'json'
require 'mysql2'
require 'xmlsimple'

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

@available_keys = %w(title country tvrage_id start_date end_date classification genres runtime network
  airtime airday alternate_titles flagged imdb_id languages writers actors plot_summary award_wins
  award_nominations imdb_rating imdb_votes flag)


def search_for_imdb(show_title, start_year = nil)
  # get IMDb/OMDb ID for each show
  start_year ? sy ="&y=#{start_year}" : sy = ''
  omdb_id_url = "http://www.omdbapi.com/?s=#{show_title.gsub(/\W/, '+') }#{sy}&type=series&r=json"
  omdb_id_uri = URI.parse(omdb_id_url)
  omdb_id_response = Net::HTTP.get_response(omdb_id_uri)

  omdb_id_data = JSON.parse(omdb_id_response.body)

  imdb_id = ''
  unless omdb_id_data["Response"] == "False"
    if omdb_id_data["Search"].length < 2
      show_data["imdb_id"] = omdb_id_data["Search"][0]["imdbID"]
    elsif omdb_id_data["Search"].length == 0
      puts "no omdb data for #{show_title}"
    else
      imdb_ids = []
      omdb_id_data["Search"].each do |result|
        imdb_ids.push result["imdbID"]
      end
      imdb_id = imdb_ids[0]
    end
  end
  imdb_id
end


def update_imdb(imdb_id, show_data)

  show_data["imdb_id"] = imdb_id

  omdb_show_url = "http://www.omdbapi.com/?i=#{show_data["imdb_id"]}&plot=full&r=json"
  omdb_show_uri = URI.parse(omdb_show_url)
  omdb_show_response = Net::HTTP.get_response(omdb_show_uri)

  omdb_data = JSON.parse(omdb_show_response.body)

  if omdb_data["Response"] == "True"

    show_data["languages"] = omdb_data["Language"].split(",").map {|x| x.strip}
    show_data["writers"] = omdb_data["Writer"].split(",").map {|x| x.strip}
    show_data["actors"] = omdb_data["Actors"].split(",").map {|x| x.strip}
    show_data["plot_summary"] = omdb_data["Plot"]


    # add Awards: regex for "X wins & Y nominations."
    # --> award_wins, award_nominations. If N/A, = 0
    # holy nuggets this is gross-looking
    wins = /[0-9]+/.match(/[0-9]+ wins/.match(omdb_data["Awards"]).to_s).to_s
    noms = /[0-9]+/.match(/[0-9]+ nominations/.match(omdb_data["Awards"]).to_s).to_s

    if blank?(wins)
      wins = "N/A"
    end

    if blank?(noms)
      noms = "N/A"
    end

    show_data["award_wins"] = wins
    show_data["award_nominations"] = noms

    show_data["imdb_rating"] = omdb_data["imdbRating"]
    show_data["imdb_votes"] = omdb_data["imdbVotes"]


    show_data["genres"] = show_data["genres"] | omdb_data["Genre"].split(",").map {|x| x.strip}

    if blank?(show_data["runtime"])
      show_data["runtime"] = omdb_data["Runtime"]
    end

  else
    puts 'aah'
  end
  show_data
end

def update_tvr(tvrage_id)
  begin
    show_data = {}

    tvrage_show_url = "http://services.tvrage.com/feeds/showinfo.php?sid=#{tvrage_id}"
    tvrage_show_uri = URI.parse(tvrage_show_url)
    tvrage_show_response = Net::HTTP.get_response(tvrage_show_uri)

    tvr_data = XmlSimple.xml_in(tvrage_show_response.body)
  rescue EOFError, Net::ReadTimeout => e
    puts e.message
    puts tvrage_id
  end

  begin

    $tvr_fields.each do |key|
      unless tvr_data.respond_to? key
        tvr_data[key] = ['']
      end
    end

    $tvr_arrays.each do |key|
      unless tvr_data.respond_to? key
        tvr_data[key] = [{'genre' => '', 'aka' => ''}]
      end
    end

    show_data["title"] = tvr_data["showname"][0]
    show_data["country"] = tvr_data["origin_country"][0]
    show_data["tvrage_id"] = tvrage_id

    show_data["start_date"] = tvr_data["startdate"][0]
    show_data["end_date"] = tvr_data["ended"][0]
    show_data["classification"] = tvr_data["classification"][0]
    show_data["genres"] = tvr_data["genres"][0]["genre"]
    show_data["runtime"] = tvr_data["runtime"][0]

    tvr_data["network"].each do |network|
      if network["country"] == show_data["country"]
        show_data["network"] = network["content"]
      end
    end
    show_data["airtime"] = "#{tvr_data["airtime"][0]} #{tvr_data["timezone"][0]}"
    show_data["airday"] = tvr_data["airday"]

    alternate_titles = {}

    tvr_data["akas"][0]["aka"].each do |aka|
      if aka.kind_of?(String)
        unless aka == ''
          alternate_titles["Alternate title"] = aka["content"]
        end
      elsif aka["country"] == show_data["country"] && !aka["attr"].nil?
        alternate_titles[aka["attr"]] = aka["content"]
      elsif aka["country"].nil?
        alternate_titles["Alternate title"] = aka["content"]
      else
        alternate_titles[aka["country"]] = aka["content"]
      end
    end

    show_data["alternate_titles"] = alternate_titles
  rescue NoMethodError => e
    puts e.backtrace[0]
    puts "TVRage ID: #{tvrage_id}"
  end

  show_data
end


def update_record(row, show_id)
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

    network_exists = false
    @client.query("SELECT COUNT(*) FROM #{$networks} WHERE network_name = '#{row['network']}'").each do |result|
      if result['COUNT(*)'] > 0
        network_exists = true
      end
    end

    unless network_exists
      @client.query("INSERT INTO #{$networks} (network_name) VALUES ('#{row['network']}')")
    end

    insert_into_shows = "UPDATE #{$tv_shows} SET
        show_title = '#{row["title"]}', country ='#{row["country"]}', start_date = '#{start_date}', end_date = '#{end_date}',
        content_rating ='#{row["content_rating"]}', classification ='#{row["classification"]}',
        runtime = '#{runtime}', network_name = '#{row['network']}', airtime = '#{airtime}', timezone ='#{timezone}',
        plot_summary = '#{row["plot_summary"]}', award_nominations = '#{award_nominations}', award_wins = '#{award_wins}',
        imdb_rating ='#{imdb_rating}', imdb_votes = '#{imdb_votes}', imdb_id = '#{row["imdb_id"]}', tvrage_id = '#{tvrage_id}', flagged = '#{flagged}',
        flag = '#{row["flag"]}'
        WHERE show_id = #{@show_id};"

    @client.query(insert_into_shows)

    show_id = @show_id

    if row['genres'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_genres} WHERE show_id = #{@show_id}")
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
      @client.query("DELETE FROM #{$show_languages} WHERE show_id = #{@show_id}")
      row['languages'].each do |language|
        language = @client.escape(language)
        @client.query("INSERT INTO #{$show_languages} (show_id, language) VALUES (#{show_id}, '#{language}');")
      end
    end

    if row['airday'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_airdays} WHERE show_id = #{@show_id}")
      row['airday'].each do |airday|
        airday = @client.escape(airday)
        @client.query("INSERT INTO #{$show_airdays} (show_id, airday) VALUES (#{show_id}, '#{airday}');")
      end
    end

    if row['alternate_titles'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_alt_titles} WHERE show_id = #{@show_id}")
      row['alternate_titles'].each do |title|
        title = @client.escape(title)
        @client.query("INSERT INTO #{$show_alt_titles} (show_id, alt_title) VALUES (#{show_id}, '#{title}');")
      end
    end

    if row['actors'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_actors} WHERE show_id = #{@show_id}")
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
        begin
          @client.query("INSERT INTO #{$show_actors} (show_id, actor_id) VALUES (#{show_id}, #{actor_id});")
        rescue Mysql2::Error => e
          puts e
        end

      end
    end


    if row['writers'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_creators} WHERE show_id = #{@show_id}")
      row['writers'].each do |creator|

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

  end
end


def new_record(row)
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

    network_exists = false
    @client.query("SELECT COUNT(*) FROM #{$networks} WHERE network_name = '#{row['network']}'").each do |result|
      if result['COUNT(*)'] > 0
        network_exists = true
      end
    end

    unless network_exists
      @client.query("INSERT INTO #{$networks} (network_name) VALUES ('#{row['network']}')")
    end

    insert_into_shows = "INSERT INTO #{$tv_shows} (show_title, country, start_date, end_date, content_rating, classification,
        runtime, network_name, airtime, timezone, plot_summary, award_nominations, award_wins, imdb_rating, imdb_votes, imdb_id,
        tvrage_id, flagged, flag) VALUES
        ('#{row['title']}', '#{row['country']}', '#{start_date}', '#{end_date}', '#{row['content_rating']}', '#{row['classification']}',
        '#{runtime}', '#{row['network']}', '#{airtime}', '#{timezone}', '#{row['plot_summary']}', '#{award_nominations}', '#{award_wins}',
        '#{imdb_rating}', '#{imdb_votes}', '#{row['imdb_id']}', '#{tvrage_id}', '#{flagged}',' #{row['flag']}' );"

    @client.query(insert_into_shows)

    show_id_query = @client.query("SELECT show_id FROM #{$tv_shows} WHERE show_title LIKE '#{row['title']}' AND network_name LIKE '#{row['network']}' LIMIT 1")

    show_id = 0

    show_id_query.each do |result|
      show_id = result['show_id']
    end

    if row['genres'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_genres} WHERE show_id = #{show_id}")
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
      @client.query("DELETE FROM #{$show_languages} WHERE show_id = #{show_id}")
      row['languages'].each do |language|
        language = @client.escape(language)
        @client.query("INSERT INTO #{$show_languages} (show_id, language) VALUES (#{show_id}, '#{language}');")
      end
    end

    if row['airday'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_airdays} WHERE show_id = #{show_id}")
      row['airday'].each do |airday|
        airday = @client.escape(airday)
        @client.query("INSERT INTO #{$show_airdays} (show_id, airday) VALUES (#{show_id}, '#{airday}');")
      end
    end

    if row['alternate_titles'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_alt_titles} WHERE show_id = #{show_id}")
      row['alternate_titles'].each do |title|
        title = @client.escape(title)
        @client.query("INSERT INTO #{$show_alt_titles} (show_id, alt_title) VALUES (#{show_id}, '#{title}');")
      end
    end

    if row['actors'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_actors} WHERE show_id = #{show_id}")
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
        begin
          @client.query("INSERT INTO #{$show_actors} (show_id, actor_id) VALUES (#{show_id}, #{actor_id});")
        rescue Mysql2::Error => e
          puts e
        end

      end
    end


    if row['writers'].instance_of?(Array)
      @client.query("DELETE FROM #{$show_creators} WHERE show_id = #{show_id}")
      row['writers'].each do |creator|

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

  end
end
