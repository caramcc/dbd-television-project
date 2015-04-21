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

result = @client.query("SELECT *, DATEDIFF(end_date, start_date) as days_ran
	FROM #{$tv_shows} WHERE show_title LIKE '#{show_title}'")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_genres
  AS
  SELECT sg.*, s.show_title
  FROM #{$tv_shows} s
  JOIN #{$show_genres} sg ON sg.show_id = s.show_id")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_languages
  AS
  SELECT sl.*, s.show_title
  FROM #{$tv_shows} s
  JOIN #{$show_languages} sl ON sl.show_id = s.show_id")

genres = @client.query("SELECT genre
FROM caramcc_all_show_genres
WHERE show_title LIKE '#{show_title}';")
languages = @client.query("SELECT language
FROM caramcc_all_show_languages
WHERE show_title LIKE '#{show_title}';")


result.each do |row|
	# puts "Show Title: #{row['show_title']}"
  row.each do |key, value|
    puts "#{key.capitalize}: #{value}"
  end
end

puts 'Genres: '
genres.each do |row|
  puts row['genre']
end

puts 'Languages:'
languages.each do |row|
  puts row['language']
end
