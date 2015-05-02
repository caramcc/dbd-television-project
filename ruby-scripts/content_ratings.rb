# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

imdb_shows = @client.query("SELECT imdb_id FROM #{$tv_shows} WHERE imdb_id NOT LIKE '';")

imdb_shows.each do |show|
  imdb_id = show['imdb_id']

  omdb_show_url = "http://www.omdbapi.com/?i=#{imdb_id}&plot=full&r=json"
  omdb_show_uri = URI.parse(omdb_show_url)
  omdb_show_response = Net::HTTP.get_response(omdb_show_uri)

  begin
    omdb_data = JSON.parse(omdb_show_response.body)
  rescue JSON::ParserError
    puts imdb_id
    next
  end

  if omdb_data["Response"] == 'True'

    rating = omdb_data["Rated"]

    @client.query("UPDATE #{$tv_shows} SET content_rating='#{rating}'
        WHERE imdb_id LIKE '#{imdb_id}';")

    puts "Updated #{imdb_id}, Rating = #{rating}"

  else
    puts 'aah'
  end
end
