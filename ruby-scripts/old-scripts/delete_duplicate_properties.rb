# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

res = @client.query("SELECT * FROM #{$show_genres}")

all_genres = {}
res.each do |r|
  all_genres[r['genre']] ||= []
  all_genres[r['genre']].push r['show_id']
end


all_genres.each do |genre, shows|
  shows.uniq!
  shows.each do |show_id|
    @client.query("INSERT INTO caramcc_show_genres2 (show_id, genre) VALUES ('#{show_id}', '#{genre}')")
  end
end