require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")


lim = 20

@client.query("CREATE OR REPLACE VIEW caramcc_all_shows_languages
  AS
  SELECT sl.*, s.show_title
  FROM #{$tv_shows} s
  JOIN #{$show_languages} sl ON sl.show_id = s.show_id")

result = @client.query("SELECT show_title FROM caramcc_all_shows_languages WHERE language LIKE '%RU%'")

# result = @client.query("SELECT s1.show_title AS s1t, s2.show_title AS s2t, COUNT(i1.genre) AS genres_in_common
# FROM #{$tv_shows} s1
# JOIN #{$tv_shows} s2 ON s2.show_id < s1.show_id AND s1.imdb_rating > 8.6 AND s2.imdb_rating > 8.6
# JOIN #{$show_genres} i1 ON i1.show_id = s1.show_id
# WHERE EXISTS (SELECT 1
#               FROM #{$tv_shows} s
#               JOIN #{$show_genres} i on i.show_id = s.show_id
#              WHERE i.genre = i1.genre
#                AND s.show_id = s2.show_id)
# GROUP BY s1.show_title, s2.show_title
# ORDER BY genres_in_common DESC, s1.show_title, s2.show_title")

# result = @client.query("SELECT show_title FROM (SELECT show_title, imdb_rating
# FROM caramcc_popular_shows_genres
# WHERE genre REGEXP
#   (SELECT GROUP_CONCAT(DISTINCT genre ORDER BY genre ASC SEPARATOR '|') FROM caramcc_popular_shows_genres
#   WHERE show_title LIKE '%Legend of Korra%')
# AND show_title NOT LIKE '%Legend of Korra%'
# AND network_name LIKE '%nick%'
# AND imdb_rating ORDER BY COUNT(show_title) DESC LIMIT #{lim}) AS t
# ")

# "SELECT first_user.id_user, second_user.id_user, COUNT(first_user.id_user) AS total_matches
#
# FROM likes AS first_user
#
# JOIN likes AS second_user
# ON second_user.id_artist = first_user.id_artist
# AND second_user.id_user != first_user.id_user
#
# GROUP BY first_user.id_user, second_user.id_user
#
# ORDER BY total_matches DESC
#
# LIMIT 1"

# result = @client.query("SELECT genre FROM caramcc_popular_shows_genres
#   WHERE show_title LIKE '%Legend of Korra%' LIMIT 1")

#
# "SELECT screen_name
# FROM caramcc_Exam1_user_tweet_tags
# WHERE tag_id LIKE ( SELECT MAX(tag_id)
#                     FROM caramcc_Exam1_user_tweet_tags
#                     WHERE user_id = #{user_id} LIMIT 1 )
# AND user_id NOT LIKE #{user_id}
# ORDER BY COUNT(*) DESC LIMIT 20
# "
#
# result = @client.query("SELECT s1.show_title FROM caramcc_popular_shows_genres s1
# INTERSECT
# SELECT s2.show_title FROM caramcc_popular_shows_genres s2 WHERE s2 NOT LIKE 's1'
# LIMIT #{lim};")




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
#   puts "#{row['s1t']} and #{row['s2t']} [#{row['genres_in_common']} genres in common]"
# end

result.each do |row|
  puts "#{row['show_title']}"
end

# result.each do |row|
#   puts "#{row['show_title']}"
#   # puts "#{row['s1.show_title']}"
#   # puts "#{row['s2.show_title']}"
# end
#
# result.each do |row|
#   puts "#{row['network_name']} - #{row['avg_rating']}"
# end

# result.each do |row|
#   puts "#{row['genre']} "
# end
