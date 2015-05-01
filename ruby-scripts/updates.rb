require 'net/http'
require 'json'
require 'mysql2'
require 'xmlsimple'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

last_update_result = @client.query("SELECT update_unix_time FROM #{$updates} ORDER BY update_unix_time DESC LIMIT 1")

last_update = Time.now.to_i
last_update_result.each do |row|
  last_update = row['update_unix_time']
end

# query TV Rage for changes since last checked
tvr_ids = []
begin
  tvrage_updates_url = "http://services.tvrage.com/feeds/last_updates.php?since=#{last_update}"
  tvrage_updates_uri = URI.parse(tvrage_updates_url)
  now = Time.now.to_i
  tvrage_updates_response = Net::HTTP.get_response(tvrage_updates_uri)

  tvr_updates_data = XmlSimple.xml_in(tvrage_updates_response.body)

  tvr_updates_data['show'].each do |show|
    tvr_ids.push show['id']
  end
rescue EOFError, Net::ReadTimeout => e
  puts e.message
end

# find all shows that have been updated in DB

tvr_ids.each do |tvrage_id|

  # query TV rage for show details

  begin
    show_data = {}

    tvrage_show_url = "http://services.tvrage.com/feeds/showinfo.php?sid=#{tvrage_id}"
    tvrage_show_uri = URI.parse(tvrage_show_url)
    tvrage_show_response = Net::HTTP.get_response(tvrage_show_uri)

    tvr_data = XmlSimple.xml_in(tvrage_show_response.body)
  rescue EOFError, Net::ReadTimeout => e
    puts e.message
    puts tvrage_id
  end

  updated_show_result = @client.query("SELECT * FROM #{$tv_shows} WHERE tvrage_id = #{tvrage_id}")

  updated_show_result.each do |row|


  end



  begin

    show_data["title"] = tvr_data["showname"][0]
    show_data["country"] = tvr_data["origin_country"][0]
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
    show_data["airtime"] = tvr_data["airtime"][0]
    show_data["timezone"] = tvr_data["timezone"][0]
    show_data["airday"] = tvr_data["airday"][0]

    alternate_titles = {}

    tvr_data["akas"][0]["aka"].each do |aka|
      if aka.kind_of?(String)
        alternate_titles["Alternate title"] = aka["content"]
      elsif aka["country"] == show_data["country"] && !aka["attr"].nil?
        alternate_titles[aka["attr"]] = aka["content"]
      elsif aka["country"].nil?
        alternate_titles["Alternate title"] = aka["content"]
      else
        alternate_titles[aka["country"]] = aka["content"]
      end
    end

    show_data["alternate_titles"] = alternate_titles
  rescue NoMethodError => e
    puts e.backtrace[0]
    puts "TVRage ID: #{tvrage_id}"
  end


end