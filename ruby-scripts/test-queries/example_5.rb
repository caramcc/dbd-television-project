require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 5
# I want to determine which TV Show made by a given Creator had the most seasons.

creator = 'J.J. Abrams'

result = @client.query("SELECT * FROM #{$tv_shows} WHERE creators LIKE '%#{creator}%';")

result.each do |row|
  puts row['show_title']
end