require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 1
# I want to determine the TV Show a given Actor has appeared in most recently.

actor = 'Hugh Laurie'

result = @client.query("SELECT a.*, s.start_date, s.show_title FROM #{$tv_shows} s JOIN #{$show_actors} sa ON sa.show_id JOIN #{$actors} a ON a.actor_id = sa.actor_id WHERE actor_name LIKE '#{actor}' ORDER BY s.start_date DESC LIMIT 1;")

result.each do |row|
  puts row['title']
end