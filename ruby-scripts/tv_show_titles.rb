require 'net/http'
require "uri"
require 'json'
require 'xmlsimple'


tvrage_titles_url = URI.parse "http://services.tvrage.com/feeds/show_list.php"
tvrage_titles_uri = URI(tvrage_titles_url)
tvrage_titles_response = Net::HTTP.get_response(tvrage_titles_uri)

tvrage_titles_data = XmlSimple.xml_in(tvrage_titles_response.body)


overall_data = {}
# overall_data should ultimately look like:
# { "The Legend of Korra" => {
# 	"tvrage id" => "26254",
# 	"country" => "US"
# 	}
# }

tvrage_titles_data["show"].each do |show|
	unless show["status"][0].to_i % 4 == 0
		if overall_data[show["name"][0]].nil?
			overall_data[show["name"][0]] = 
			{
				"tvrage_id" => show["id"][0],
				"country" => show["country"][0]
			}
		end
	end
end


#  copy titles to json file
file_path = "caramcc_tv_show_titles_#{Time.now.to_i}.json"

# block is preferred syntax, closes file automatically when block terminates.
File.open(file_path, 'w') { |file| file.write(overall_data.to_json) }

