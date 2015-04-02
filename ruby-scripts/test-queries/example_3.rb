require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 3
# I want to determine which genres a given Actor appears in most frequently.

actor = 'Hugh Laurie'

result = @client.query("SELECT sg.*, a.*, s.show_id, COUNT(sg.genre)
FROM #{$actors} a
JOIN #{$show_actors} sa ON a.actor_id = sa.actor_id
JOIN #{$tv_shows} s ON sa.show_id = s.show_id
JOIN #{$show_genres} sg ON s.show_id = sg.show_id
WHERE a.actor_name LIKE '#{actor}'")

result.each do |row|
  puts row['genre']
end