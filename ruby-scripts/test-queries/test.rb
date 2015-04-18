require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")



# result = @client.query("SELECT network_name FROM #{$tv_shows} ORDER BY imdb_votes DESC LIMIT 20;")
result = @client.query("SELECT network_name, avg_rating
FROM (
SELECT network_name, AVG(imdb_rating) as avg_rating, AVG(imdb_votes) as avg_votes FROM #{$tv_shows}
WHERE imdb_rating > 0.0 AND network_name NOT LIKE ''
GROUP BY network_name
HAVING COUNT(*) > 20 AND avg_votes > 2000) t
ORDER BY avg_rating DESC LIMIT 20")

result.each do |row|
  puts "#{row['network_name']} - #{row['avg_rating']}"
end
