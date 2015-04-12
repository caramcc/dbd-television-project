require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 3
# I want to determine which genres a given Actor appears in most frequently.

actor = 'Hugh Laurie'

@client.query("CREATE OR REPLACE VIEW caramcc_actor_genre_frequency
  AS
  SELECT sg.genre, a.actor_name
  FROM #{$actors} a
  JOIN #{$show_actors} sa ON a.actor_id = sa.actor_id
  JOIN #{$tv_shows} s ON sa.show_id = s.show_id
  JOIN #{$show_genres} sg ON s.show_id = sg.show_id")

result = @client.query("SELECT MAX(genre)
FROM caramcc_actor_genre_frequency
WHERE actor_name LIKE '#{actor}'")

result.each do |row|
  puts row['MAX(genre)']
end