require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)
@client.query("USE #{$db_name}")

@client.query("SELECT DISTINCT network FROM #{$tv_shows};").each do |network|
  unless network['network_name'].nil?
    @client.query("INSERT INTO #{$networks} (network_name) VALUES ('#{network['network_name']}');")
  end
end

file_path = 'caramcc_twitter_handles.json'
file = File.read(file_path)
twitter_handle_data = JSON.parse(file)

twitter_handle_data['show_data'].each do |show, handle|
  @client.query("UPDATE #{$tv_shows} SET show_twitter_id = '#{handle['twitter_handle']}' WHERE show_title LIKE '#{@client.escape(show)}';")
end

twitter_handle_data["network_data"].each do |network, handle|
  @client.query("UPDATE #{$networks} SET network_twitter_id = '#{handle['twitter_handle']}' WHERE network_name LIKE '#{@client.escape(network)}';")
end