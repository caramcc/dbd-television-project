require 'net/http'
require 'json'
require 'mysql2'
require 'xmlsimple'

require_relative 'constants.rb'
require_relative 'update_functions.rb'

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
new_show_ids = []

tvr_ids.uniq!

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

  if updated_show_result.nil?
    new_show_ids.push tvrage_id
  else
    updated_show_result.each do |row|
      show_id = row['show_id']
      show_title = row['show_title']
      start_year = row['start_date'][0..3]
      start_year == '1000' ? start_year = nil : true
      puts "updating record for TVR #{tvrage_id} (title: #{show_title} (#{start_year})"
      update_record(update_imdb(search_for_imdb(show_title, start_year), update_tvr(tvrage_id)), show_id)
    end
  end
end

new_show_ids.each do |tvrage_id|
  show_hash = update_tvr(tvrage_id)
  show_title = show_hash['title']
  start_year = show_hash['start_date'][0..3]
  start_year == '1000' ? start_year = nil : true
  puts "Adding NEW record for TVR #{tvrage_id} (title: #{show_title} (#{start_year})"
  new_record(update_imdb(search_for_imdb(show_title, start_year), show_hash))
end