# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 1
# I want to determine the TV Show a given Actor has appeared in most recently.

actor = 'Hugh Laurie'

@client.query("CREATE OR REPLACE VIEW caramcc_actors_most_recent_shows
  AS
  SELECT a.*, s.start_date, s.show_title FROM #{$tv_shows} s
  JOIN #{$show_actors} sa ON sa.show_id = s.show_id
  JOIN #{$actors} a ON a.actor_id = sa.actor_id")

result = @client.query("SELECT show_title FROM caramcc_actors_most_recent_shows
  WHERE actor_name LIKE '#{actor}'
  ORDER BY start_date DESC LIMIT 1;")

result.each do |row|
  puts row['show_title']
end