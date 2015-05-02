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

networks = []
@client.query("SELECT network_name FROM #{$tv_shows};").each do |network|
  networks.push network['network_name'] unless network['network_name'].nil?
  puts network
end

networks = networks.map{|i| i.downcase}.uniq


file_path = 'caramcc_twitter_handles.json'
file = File.read(file_path)
twitter_handle_data = JSON.parse(file)

twitter_handle_data['show_data'].each do |show, handle|
  @client.query("UPDATE #{$tv_shows} SET show_twitter_id = '#{handle['twitter_handle']}' WHERE show_title LIKE '#{@client.escape(show)}';")
end

twitter_handle_data['network_data'].each do |network, handle|
  @client.query("UPDATE #{$networks} SET network_twitter_id = '#{handle['twitter_handle']}' WHERE network_name LIKE '#{network}';")
end