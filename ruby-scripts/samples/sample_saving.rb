# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require "uri"
require 'json'


# title = "Skins"
# start_year = 2007

# omdb_url = "http://www.omdbapi.com/?s=#{title}&y=#{start_year}&type=series&plot=short&r=json"



imdb_ids = ["tt0840196", "tt0098745", "tt0903747"]
#  just in case shit breaks later on:
file_path = "test_caramcc_tv_shows"

imdb_ids.each do |imdb_id|
	ehash = {}
	omdb_url = "http://www.omdbapi.com/?i=#{imdb_id}&plot=full&r=json"
	omdb_uri = URI.parse(omdb_url)
	omdb_response = Net::HTTP.get_response(omdb_uri)

	omdb_data = JSON.parse(omdb_response.body)

	omdb_data.each do |key, value|
		if key[0] == "i" || key[0] == "R"
			ehash[key] = value
		end
	end

	File.open(file_path, 'a') { |file| file.puts(ehash.to_json) }
end