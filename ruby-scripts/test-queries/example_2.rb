require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 2
# I want to determine which is the lowest-rated TV Show made by a given Creator.

creator = 'J.J. Abrams'

result = @client.query(
    "SELECT c.*, s.imdb_rating, s.show_title
FROM #{$tv_shows} s
JOIN #{$show_creators} sc ON sc.show_id = s.show_id
JOIN #{$creators} c ON c.creator_id = sc.creator_id
WHERE creator_name LIKE '%#{creator}%'
ORDER BY s.imdb_rating ASC LIMIT 1")

result.each do |row|
  puts row['show_title']
end