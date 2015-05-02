# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require "uri"
require 'json'
require 'xmlsimple'

tvrage_id = 27
tvrage_show_url = "http://services.tvrage.com/feeds/showinfo.php?sid=#{tvrage_id}"
tvrage_show_uri = URI.parse(tvrage_show_url)
tvrage_show_response = Net::HTTP.get_response(tvrage_show_uri)

tvrage_show_data = XmlSimple.xml_in(tvrage_show_response.body)

puts tvrage_show_data