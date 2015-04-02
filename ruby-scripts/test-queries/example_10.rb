require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 10
# I want to determine which TV Show broadcast in the UK has received the most IMDB votes.


result = @client.query("SELECT show_title FROM #{$tv_shows} WHERE country LIKE 'UK' ORDER BY imdb_votes DESC LIMIT 1 ")

result.each do |row|
  puts row['show_title']
end