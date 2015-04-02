require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 2
# I want to determine which is the lowest-rated TV Show made by a given Creator.

creator = 'Abrams'

result = @client.query(
    "SELECT * FROM #{$creators} LIMIT 50")

result.each do |row|
  puts row['creator_name']
  # puts row
end