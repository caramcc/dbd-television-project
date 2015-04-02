require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 8
# I want to determine the titles of all the shows broadcast on NBC.


result = @client.query("SELECT show_title FROM #{$tv_shows} WHERE network LIKE 'NBC' ")

result.each do |row|
  puts row['show_title']
end