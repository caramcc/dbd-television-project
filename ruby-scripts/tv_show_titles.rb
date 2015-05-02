# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require 'uri'
require 'json'
require 'xmlsimple'


@active_tvr_statuses = [1, 4, 7, 9]

def is_active?(status)
  @active_tvr_statuses.include?(status)
end

tvrage_titles_url = URI.parse 'http://services.tvrage.com/feeds/show_list.php'
tvrage_titles_uri = URI(tvrage_titles_url)
tvrage_titles_response = Net::HTTP.get_response(tvrage_titles_uri)

tvrage_titles_data = XmlSimple.xml_in(tvrage_titles_response.body)


overall_data = {}
# overall_data should ultimately look like:
# { "The Legend of Korra" => {
# 	  "tvrage id" => "26254",
# 	  "country" => "US"
# 	},
# }

unaired_shows = {}

tvrage_titles_data['show'].each do |show|
  # don't want shows where tvr status == 4, 8, or 12
	if show['status'][0].to_i % 4 == 0
    # don't want shows where title contains cyrillic
    # (provides false results in OMDb searches)
    unless show['name'][0].match(/\p{Cyrillic}/)
      if unaired_shows[show['name'][0]].nil?
        unaired_shows[show['name'][0]] =
            {
                'tvrage_id' => show['id'][0],
                'country' => show['country'][0],
                'active' => false
            }
      end
    end

  else

    unless show['name'][0].match(/\p{Cyrillic}/)
      if overall_data[show['name'][0]].nil?
        overall_data[show['name'][0]] =
        {
          'tvrage_id' => show['id'][0],
          'country' => show['country'][0],
          'active' => is_active?(show['status'][0])
        }
      end
    end
	end
end


#  copy titles to json file
file_path = "caramcc_tv_show_titles_#{Time.now.to_i}.json"
unaired_file_path = "caramcc_unaired_show_titles_#{Time.now.to_i}.json"

# block is preferred syntax, closes file automatically when block terminates.
File.open(file_path, 'w') { |file| file.write(JSON.pretty_generate(overall_data)) }
File.open(unaired_file_path, 'w') { |file| file.write(JSON.pretty_generate(unaired_shows)) }

