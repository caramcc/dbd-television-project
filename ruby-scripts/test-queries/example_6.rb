require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 6
# I want to determine the Network that has aired the most TV Shows in the United States.


result = @client.query("SELECT MAX(network_name) FROM #{$tv_shows}
WHERE country LIKE 'US' OR country LIKE 'USA' OR country LIKE 'United States%'
LIMIT 1")

result.each do |row|
  puts row['MAX(network_name)']
end