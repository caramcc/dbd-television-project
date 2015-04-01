require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 1
# I want to determine the TV Show a given Actor has appeared in most recently.

actor = 'Hugh Laurie'
creator = 'J.J. Abrams'
tv_show = 'Breaking Bad'

result = @client.query("SELECT * FROM #{$tv_shows} WHERE actors LIKE '%#{actor}%';")

result.each do |row|
  puts row['show_title']
end