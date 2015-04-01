require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 2
# I want to determine which is the lowest-rated TV Show made by a given Creator.

creator = 'J.J. Abrams'

result = @client.query("SELECT * FROM #{$tv_shows} WHERE actors LIKE '%#{creator}%';")

result.each do |row|
  puts row['show_title']
end