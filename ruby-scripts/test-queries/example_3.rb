require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 3
# I want to determine which genres a given Actor appears in most frequently.

actor = 'Hugh Laurie'

result = @client.query("SELECT sg.*, a.actor_id, s.show_id, COUNT(DISTINCT sg.genre)
FROM #{$tv_shows} s
JOIN #{$show_actors} sa ON sa.show_id = s.show_id
JOIN #{$actors} a ON a.actor_id = sa.actor_id
JOIN #{$show_genres} sg ON sa.show_id = sg.show_id
WHERE actor_name LIKE '#{actor}'
ORDER BY COUNT(DISTINCT sg.genre) DESC LIMIT 1;")

result.each do |row|
  puts row['genre']
  puts row
end