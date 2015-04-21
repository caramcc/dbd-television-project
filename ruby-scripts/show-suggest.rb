require 'net/http'
require 'json'
require 'mysql2'

require_relative 'constants.rb'

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
results = {}

by_genre = @client.query("SELECT s1.show_title, s1.classification as s1c, s1.network_name as s1n, s2.classification, s2.network_name, s2.imdb_rating, s2.award_wins, s2.award_nominations, DATEDIFF(s2.end_date, s2.start_date) as days_ran, s2.show_title AS s2t, COUNT(i1.genre) AS genres_in_common
FROM #{$tv_shows} s1
JOIN #{$tv_shows} s2 ON s1.show_title LIKE '#{show_title}' AND s2.imdb_rating > 7 AND s2.show_title NOT LIKE '#{show_title}' AND s2.imdb_votes > 1000
JOIN #{$show_genres} i1 ON i1.show_id = s1.show_id
WHERE EXISTS (SELECT 1
              FROM #{$tv_shows} s
              JOIN #{$show_genres} i ON i.show_id = s.show_id
             WHERE i.genre = i1.genre
               AND s.show_id = s2.show_id)
GROUP BY s1.show_title, s2.show_id
ORDER BY genres_in_common DESC, s1.show_title, s2.show_id")

by_cast = @client.query("SELECT s1.show_title, s1.classification as s1c, s1.network_name as s1n, s2.classification, s2.network_name, s2.imdb_rating, s2.award_wins, s2.award_nominations, DATEDIFF(s2.end_date, s2.start_date) as days_ran, s2.show_title AS s2t, COUNT(i1.actor_id) AS actors_in_common
FROM #{$tv_shows} s1
JOIN #{$tv_shows} s2 ON s1.show_title LIKE '#{show_title}' AND s2.imdb_rating > 7 AND s2.show_title NOT LIKE '#{show_title}' AND s2.imdb_votes > 1000
JOIN #{$show_actors} i1 ON i1.show_id = s1.show_id
WHERE EXISTS (SELECT 1
              FROM #{$tv_shows} s
              JOIN #{$show_actors} i ON i.show_id = s.show_id
             WHERE i.actor_id = i1.actor_id
               AND s.show_id = s2.show_id)
GROUP BY s1.show_title, s2.show_id
ORDER BY actors_in_common DESC, s1.show_title, s2.show_id")

by_crew = @client.query("SELECT s1.show_title, s1.classification as s1c, s1.network_name as s1n, s2.classification, s2.network_name, s2.imdb_rating, s2.award_wins, s2.award_nominations, DATEDIFF(s2.end_date, s2.start_date) as days_ran, s2.show_title AS s2t, COUNT(i1.creator_id) AS creators_in_common
FROM #{$tv_shows} s1
JOIN #{$tv_shows} s2 ON s1.show_title LIKE '#{show_title}' AND s2.imdb_rating > 7 AND s2.show_title NOT LIKE '#{show_title}' AND s2.imdb_votes > 1000
JOIN #{$show_creators} i1 ON i1.show_id = s1.show_id
WHERE EXISTS (SELECT 1
              FROM #{$tv_shows} s
              JOIN #{$show_creators} i ON i.show_id = s.show_id
             WHERE i.creator_id = i1.creator_id
               AND s.show_id = s2.show_id)
GROUP BY s1.show_title, s2.show_id
ORDER BY creators_in_common DESC, s1.show_title, s2.show_id")


s1 = {}

by_genre.each do |row|
	results[row['s2t']] ||= {}
	results[row['s2t']]['total_in_common'] ||= 0
	results[row['s2t']]['total_in_common'] = row['genres_in_common']
	results[row['s2t']]['days_ran'] = row['days_ran']
	results[row['s2t']]['imdb_rating'] = row['imdb_rating']
	results[row['s2t']]['award_wins'] = row['award_wins']
	results[row['s2t']]['award_nominations'] = row['award_nominations']
	results[row['s2t']]['genres_in_common'] = row['genres_in_common']
	results[row['s2t']]['classification'] = row['classification']
	results[row['s2t']]['network_name'] = row['network_name']
  s1['network_name'] = row['s1n']
  s1['classification'] = row['s1c']
  # puts "#{row['s1t']} and #{row['s2t']} [#{row['genres_in_common']} genres in common]"
end

by_cast.each do |row|
	results[row['s2t']] ||= {}
	results[row['s2t']]['total_in_common'] ||= 0
	results[row['s2t']]['total_in_common'] += row['actors_in_common']
	results[row['s2t']]['days_ran'] = row['days_ran']
	results[row['s2t']]['imdb_rating'] = row['imdb_rating']
	results[row['s2t']]['award_wins'] = row['award_wins']
	results[row['s2t']]['award_nominations'] = row['award_nominations']
	results[row['s2t']]['actors_in_common'] = row['actors_in_common']
  results[row['s2t']]['classification'] = row['classification']
  results[row['s2t']]['network_name'] = row['network_name']
  s1['network_name'] = row['s1n']
  s1['classification'] = row['s1c']
  # puts "#{row['s1t']} and #{row['s2t']} [#{row['actors_in_common']} actors in common]"
end

by_crew.each do |row|
	results[row['s2t']] ||= {}
	results[row['s2t']]['total_in_common'] ||= 0
	results[row['s2t']]['total_in_common'] += row['creators_in_common']
	results[row['s2t']]['days_ran'] = row['days_ran']
	results[row['s2t']]['imdb_rating'] = row['imdb_rating']
	results[row['s2t']]['award_wins'] = row['award_wins']
	results[row['s2t']]['award_nominations'] = row['award_nominations']
	results[row['s2t']]['creators_in_common'] = row['creators_in_common']
  results[row['s2t']]['classification'] = row['classification']
  results[row['s2t']]['network_name'] = row['network_name']
  s1['network_name'] = row['s1n']
  s1['classification'] = row['s1c']
  # puts "#{row['s1t']} and #{row['s2t']} [#{row['creators_in_common']} creators in common]"
end

output = []

results.each do |show, show_hash|
  show_hash['network_name'] == s1['network_name'] ? nn = 30 : nn = 0
  show_hash['classification'] == s1['classification'] ? classification = 50 : classification = 0
	show_hash['days_ran'] <= 200 ? awards = 0 : awards = (365 * (show_hash['award_nominations'] + (2 * show_hash['award_wins']))) / show_hash['days_ran']

	likability_index =  20 * show_hash['total_in_common'] + (10 * show_hash['imdb_rating']) + awards + nn + classification
	li_string = "#{show_hash['total_in_common']} in common | #{show_hash['imdb_rating']} imdb rating | #{awards} award pts
        | #{classification} class | #{nn} network |||| #{likability_index} li"
	output.push [show, likability_index, li_string, show_hash]
end

output.sort! {|x, y| y[1] <=> x[1]}

i = 0
output.each do |value|
  if i < 20
	  puts "#{value[0]} (#{value[1]})"
    # puts value[3]
	  i += 1
  else
    break
  end
end