require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")


lim = 20

@client.query("CREATE OR REPLACE VIEW caramcc_popular_shows_genres
  AS
  SELECT sg.*, s.show_title, s.show_id
  FROM #{$tv_shows} s
  JOIN #{$show_genres} sg ON sg.show_id = s.show_id AND s.imdb_votes > 2000 AND s.imdb_rating > 5")

# result = @client.query("SELECT network_name FROM #{$tv_shows} ORDER BY imdb_votes DESC LIMIT 20;")

# result = @client.query("SELECT network_name, avg_rating
# FROM (
# SELECT network_name, AVG(imdb_rating) as avg_rating, AVG(imdb_votes) as avg_votes FROM #{$tv_shows}
# WHERE imdb_rating > 0.0 AND network_name NOT LIKE ''
# GROUP BY network_name
# HAVING COUNT(*) > 20 AND avg_votes > 2000) t
# ORDER BY avg_rating DESC LIMIT 20")

# SELECT DISTINCT records.id
# FROM records
# INNER JOIN data d1 on d1.id = records.firstname AND data.value = "john"
# INNER JOIN data d2 on d2.id = records.lastname AND data.value = "smith"

# s1.show_title FROM caramcc_popular_shows_genres s1
# INTERSECT
# SELECT s2.show_title FROM caramcc_popular_shows_genres s2 WHERE s2 NOT LIKE 's1'


result = @client.query("SELECT DISTINCT s1.show_title, s2.show_title
FROM caramcc_popular_shows_genres g
INNER JOIN #{$tv_shows} s1 ON s1.show_id = g.show_id
INNER JOIN #{$tv_shows} s2 ON s2.show_id = g.show_id
LIMIT #{lim};")




# "SELECT show_title
# FROM (
# SELECT genre FROM caramcc_all_show_genres
# WHERE show_title LIKE
# )"


# select distinct
# t1.code, t1.id, t1.description, t2.id, t2.description
# from
# data t1, data t2
# where
# t1.code = t2.code and t1.id < t2.id
# order by t1.code



# result.each do |row|
#   puts "#{row['show_title']}"
# end

result.each do |row|
  puts "#{row['show_title']}"
  # puts "#{row['s1.show_title']}"
  # puts "#{row['s2.show_title']}"
end

# result.each do |row|
#   puts "#{row['network_name']} - #{row['avg_rating']}"
# end
