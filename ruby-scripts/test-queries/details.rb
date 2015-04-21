require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")


lim = 20
ARGV[1] == '-f' ? show_title = "%#{ARGV[0]}%" : show_title = ARGV[0]

@client.query("CREATE OR REPLACE VIEW caramcc_popular_shows_genres
  AS
  SELECT sg.*, s.show_title, s.imdb_rating, s.network_name
  FROM #{$tv_shows} s
  JOIN #{$show_genres} sg ON sg.show_id = s.show_id AND s.imdb_votes > 2000 AND s.imdb_rating > 5")

# result = @client.query("SELECT network_name FROM #{$tv_shows} ORDER BY imdb_votes DESC LIMIT 20;")
result = @client.query("SELECT s.*, sg.genre, sl.language,  DATEDIFF(end_date, start_date) as days_ran,  
	FROM #{$tv_shows} s
	JOIN #{$show_genres} sg ON sg.show_id = s.show_id AND s.show_title LIKE '#{show_title}'
	JOIN #{$show_languages} sl ON sl.show_id = s.show_id")


result.each do |row|
	puts "Show Title: #{row['show_title']}" 
	puts "Genres: #{row['genre']}" 
	puts "Languages: #{row['language']}" 
end



