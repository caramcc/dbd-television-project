require 'net/http'
require 'uri'
require 'json'
# require 'active_support'
require 'mysql2'

@table = 'caramcc_tv_shows'
@available_keys = %w(title country tvrage_id start_date end_date classification genres runtime network
  airtime airday alternate_titles flagged imdb_id languages writers actors plot_summary award_wins
  award_nominations imdb_rating imdb_votes flag)

def load_data
  all_data = []
  Dir.entries('output-data').drop(2).each do |file_path|
    File.open(File.join('output-data', file_path), "r") do |f|
      f.each_line do |line|
        begin
          all_data.push JSON.parse(line)
        rescue JSON::ParserError => e
          puts line
        end
      end
    end
  end
  all_data
end

@client = Mysql2::Client.new(:host => "localhost", :username => "root")


@client.query("USE caramcc_dbd_project")

# @client.query("DROP TABLE #{@table}")

@client.query("CREATE TABLE IF NOT EXISTS #{@table} (
  show_id int(11) NOT NULL AUTO_INCREMENT,
  show_title varchar(255) NOT NULL DEFAULT '',
  country varchar(255) NOT NULL DEFAULT '',
  start_date date NOT NULL DEFAULT '1000-01-01',
  end_date date NOT NULL DEFAULT '1000-01-01',
  content_rating varchar(11) NOT NULL DEFAULT '',
  classification varchar(255) NOT NULL DEFAULT '',
  genres varchar(2047) NOT NULL DEFAULT '',
  runtime int(11) NOT NULL DEFAULT '0',
  network varchar(255) NOT NULL DEFAULT '',
  airtime varchar(11) NOT NULL DEFAULT '',
  timezone varchar(63) NOT NULL DEFAULT '',
  airdays varchar(2047) NOT NULL DEFAULT '',
  languages varchar(2047) NOT NULL DEFAULT '',
  writers varchar(2047) NOT NULL DEFAULT '',
  actors varchar(2047) NOT NULL DEFAULT '',
  plot_summary text(8191) NOT NULL,
  alternate_titles varchar(2047) NOT NULL DEFAULT '',
  award_nominations int(11) NOT NULL DEFAULT '0',
  award_wins int(11) NOT NULL DEFAULT '0',
  imdb_rating float(8,3) NOT NULL DEFAULT '0',
  imdb_votes int(11) NOT NULL DEFAULT '0',
  imdb_id varchar(11) NOT NULL DEFAULT '',
  tvrage_id int(11) NOT NULL DEFAULT '0',
  flagged tinyint(1) NOT NULL DEFAULT '0',
  flag varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id)
);")



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
        elsif value.instance_of?(Hash) || value.instance_of?(Array)
          row[key] = @client.escape(value.to_s)
        end
      end

      begin
        start_date = Date.parse(row["start_date"]).to_s
        end_date = Date.parse(row["end_date"]).to_s
      rescue ArgumentError, TypeError # if invalid dates
        puts start_date
        puts end_date
        start_date ||= '1000-01-01'
        end_date ||= '1000-01-01'
      end

      runtime = row["runtime"].to_i
      award_wins = row["award_wins"].to_i
      award_nominations = row["award_nominations"].to_i
      if row["airtime"].nil?
        
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

      insert_query = "INSERT INTO #{@table} (show_title, country, start_date, end_date, 
        content_rating, classification, genres, runtime, network, airtime, timezone, 
        airdays, languages, writers, actors, plot_summary, alternate_titles, award_nominations,
        award_wins, imdb_rating, imdb_votes, imdb_id, tvrage_id, flagged, flag) VALUES (
        '#{row["title"]}', '#{row["country"]}', '#{start_date}', '#{end_date}',
        '#{row["content_rating"]}', '#{row["classification"]}', '#{row["genres"]}', '#{runtime}',
        '#{row["network"]}', '#{airtime}', '#{timezone}', '#{row["airday"]}', '#{row["languages"]}',
        '#{row["writers"]}', '#{row["actors"]}', '#{row["plot_summary"]}', 
        '#{row["alternate_titles"]}', '#{award_nominations}', '#{award_wins}', 
        '#{imdb_rating}', '#{imdb_votes}', '#{row["imdb_id"]}', '#{tvrage_id}', '#{flagged}', 
        '#{row["flag"]}'
        );"
      @client.query(insert_query)
    end
  end
end

process_data(load_data)

