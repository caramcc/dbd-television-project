require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$database}")

# Example 3
# I want to determine which genres a given Actor appears in most frequently.

actor = 'Hugh Laurie'

result = @client.query("SELECT * FROM #{$tv_shows} WHERE actors LIKE '%#{actor}%';")

result.each do |row|
  puts row['show_title']
  puts row
end