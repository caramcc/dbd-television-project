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

# Example 7
# I want to determine the average IMDB rating for shows aired on the network HBO.

network = 'HBO'

result = @client.query("SELECT AVG(imdb_rating) FROM #{$tv_shows} WHERE network_name LIKE '#{network}' AND imdb_rating > 0 ")

result.each do |row|
  puts row['AVG(imdb_rating)']
end