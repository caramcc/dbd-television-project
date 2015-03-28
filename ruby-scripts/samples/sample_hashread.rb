require 'net/http'
require "uri"
require 'json'
require 'xmlsimple'

def blank?(object) 
	if object.instance_of?(Array) || object.instance_of?(Hash)
		return object.nil? || object.length == 0
	else
		return object.nil? || object.strip == ''
	end
end

sample_json = '{"The Betty White Show":{"tvrage_id":"13","country":"US"},"Empire (1962)":{"tvrage_id":"23","country":"US"},"NYPD":{"tvrage_id":"27","country":"US"},"Baywatch":{"tvrage_id":"2733","country":"US"},"Beverly Hills, 90210":{"tvrage_id":"2776","country":"US"},"Bewitched":{"tvrage_id":"2779","country":"US"}}'

title_hash = JSON.parse(sample_json)

puts title_hash

title_hash.each do |title, hash|
	tvrage_id = hash["tvrage_id"]
	tvrage_show_url = "http://services.tvrage.com/feeds/showinfo.php?sid=#{tvrage_id}"
	tvrage_show_uri = URI.parse(tvrage_show_url)
	tvrage_show_response = Net::HTTP.get_response(tvrage_show_uri)

	tvr_data = XmlSimple.xml_in(tvrage_show_response.body)

	start_year = tvr_data["started"][0] # for OMDb query
	show_data = {}

		show_data["title"] = title
		show_data["country"] = hash["country"]
		show_data["tvrage_id"] = tvrage_id

		show_data["start_date"] = tvr_data["startdate"][0]
		show_data["end_date"] = tvr_data["ended"][0]
		show_data["classification"] = tvr_data["classification"][0]
		show_data["genres"] = tvr_data["genres"][0]["genre"]
		show_data["runtime"] = tvr_data["runtime"][0]

		tvr_data["network"].each do |network|
			if network["country"] == show_data["country"]
				show_data["network"] = network["content"]
			end
		end
		show_data["airtime"] = "#{tvr_data["airtime"][0]} #{tvr_data["timezone"][0]}"
		show_data["airday"] = tvr_data["airday"]


	omdb_id_url = "http://www.omdbapi.com/?s=#{title.gsub(/\W/, '+') }&y=#{start_year}&type=series&r=json"
	omdb_id_uri = URI.parse(omdb_id_url)
	omdb_id_response = Net::HTTP.get_response(omdb_id_uri)

	omdb_id_data = JSON.parse(omdb_id_response.body)

	unless omdb_id_data["Response"] == "False"
		if omdb_id_data["Search"].length < 2
			show_data["imdb_id"] = omdb_id_data["Search"][0]["imdbID"]
		elsif omdb_id_data["Search"].length == 0
			flag_for_manual_review = true
			flag = "no omdb data"
		else
			imdb_ids = []
			omdb_id_data["Search"].each do |result|
				imdb_ids.push result["imdbID"]
				flag_for_manual_review = true
			end
				flag = "multiple search results: ids: #{imdb_ids}"
			show_data["imdb_id"] = imdb_ids[0]
		end
		# get show data from OMDb

		omdb_show_url = "http://www.omdbapi.com/?i=#{show_data["imdb_id"]}&plot=full&r=json"
		omdb_show_uri = URI.parse(omdb_show_url)
		omdb_show_response = Net::HTTP.get_response(omdb_show_uri)

		omdb_data = JSON.parse(omdb_show_response.body)

		if omdb_data["Response"] == "True"
			unless omdb_data["Country"] == show_data["country"]
				flag_for_manual_review = true
				flag = "country not equal: omdb: #{omdb_data["Country"]}, tvr: #{show_data["country"]}"
			end

			show_data["languages"] = omdb_data["Language"].split(",").map {|x| x.strip}
			show_data["writers"] = omdb_data["Writer"].split(",").map {|x| x.strip}
			show_data["actors"] = omdb_data["Actors"].split(",").map {|x| x.strip}
			show_data["plot_summary"] = omdb_data["Plot"]


			# add Awards: regex for "X wins & Y nominations."
			# --> award_wins, award_nominations. If N/A, = 0
			# holy nuggets this is gross-looking
			wins = /[0-9]+/.match(/[0-9]+ wins/.match(omdb_data["Awards"]).to_s).to_s
			noms = /[0-9]+/.match(/[0-9]+ nominations/.match(omdb_data["Awards"]).to_s).to_s

			if blank?(wins)
			 wins = "N/A"
			end

			if blank?(noms)
			 noms = "N/A"
			end

			show_data["award_wins"] = wins
			show_data["award_nominations"] = noms

			show_data["imdb_rating"] = omdb_data["imdbRating"]
			show_data["imdb_votes"] = omdb_data["imdbVotes"]


			show_data["genres"] = show_data["genres"] | omdb_data["Genre"].split(",").map {|x| x.strip}

			if blank?(show_data["runtime"]) 
				show_data["runtime"] = omdb_data["Runtime"] 
			end

			# compare Runtime to make sure it's approx. the same show
			if (show_data["runtime"].to_i - omdb_data["Runtime"].to_i).abs > 10
				flag_for_manual_review = true
				flag = "runtime differential: omdb #{omdb_data["Runtime"]} vs tvr #{show_data["runtime"]}"
			end
		else
			flag_for_manual_review = true
			flag = "no omdb response for omdb id #{show_data[imdb_id]}"
		end
	else
		flag_for_manual_review = true
		flag = "no omdb data for show"
	end

	if flag_for_manual_review
		show_data["flagged"] = true 
		show_data["flag"] = flag
	end

	puts show_data

end