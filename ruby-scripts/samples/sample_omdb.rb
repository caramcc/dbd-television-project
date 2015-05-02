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
imdb_id = "tt0840196"
omdb_url = "http://www.omdbapi.com/?i=#{imdb_id}&plot=full&r=json"
omdb_uri = URI.parse(omdb_url)
omdb_response = Net::HTTP.get_response(omdb_uri)

omdb_data = JSON.parse(omdb_response.body)

puts omdb_data

# {
# 	"Search"=>
# 	[
# 		{
# 			"Title"=>"Skins", 
# 			"Year"=>"2007–", 
# 			"imdbID"=>"tt0840196", 
# 			"Type"=>"series"
# 		}
# 	]
# }

# {
# 	"Title"=>"Skins", 
# 	"Year"=>"2007–", 
# 	"Rated"=>"N/A", 
# 	"Released"=>"25 Jan 2007", 
# 	"Runtime"=>"46 min", 
# 	"Genre"=>"Comedy, Drama", 
# 	"Director"=>"N/A", 
# 	"Writer"=>"Jamie Brittain, Bryan Elsley", 
# 	"Actors"=>"Kaya Scodelario, Nicholas Hoult, Joe Dempsie, Hannah Murray", 
# 	"Plot"=>"The story of a group of British teens who are trying to grow up and find love and happiness despite questionable parenting and teachers who more want to be friends (and lovers) rather than authority figures.", 
# 	"Language"=>"English", 
# 	"Country"=>"UK", 
# 	"Awards"=>"7 wins & 30 nominations.", 
# 	"Poster"=>"http://ia.media-imdb.com/images/M/MV5BMjE3MzMxNjUwMF5BMl5BanBnXkFtZTcwNTkwOTE2Mg@@._V1_SX300.jpg", 
# 	"Metascore"=>"N/A", 
# 	"imdbRating"=>"8.2", 
# 	"imdbVotes"=>"51,452", 
# 	"imdbID"=>"tt0840196", 
# 	"Type"=>"series", 
# 	"Response"=>"True"
# }

# if Response
# check that country is the same
# add Language (split)
# add Writer (split)
# add Actors (split)
# add Plot
# add Awards: regex for "X wins & Y nominations."
# --> award_wins, award_nominations. If N/A, = 0
# add imdbRating
# add imdbVotes
# merge Genre (split)
# compare Runtime


