require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 7
# I want to determine the average IMDB rating for shows aired on the network HBO.


# result = @client.query("SELECT *, COUNT( FROM #{$tv_shows} GROUP BY network ")

result.each do |row|
  puts row['show_title']
end