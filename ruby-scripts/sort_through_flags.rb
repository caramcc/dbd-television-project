require 'net/http'
require "uri"
require 'json'
# require 'active_support'
require 'mysql2'

require_relative 'constants'


@client = Mysql2::Client.new(:host => $host, :username => $username)

@client.query("USE #{$db_name}")

result = @client.query("SELECT * FROM #{$tv_shows} WHERE flagged=1;")

flags = {}
result.each do |row|
  flag = row["flag"]
  title = row["show_title"]
  tvr_id = row["tvrage_id"]
  imdb_id = row["imdb_id"]
  if flags[flag].nil?
    flags[flag] = {
      count: 1,
      titles: [title],
      tvr_id: [tvr_id],
      imdb_id: [imdb_id]
    }
  else
    flags[flag] = {
      count: flags[flag][:count] += 1,
      titles: flags[flag][:titles].push(title),
      tvr_id: flags[flag][:tvr_id].push(tvr_id),
      imdb_id: flags[flag][:imdb_id].push(imdb_id)
    }
  end
end


flags.each do |flag, shows|
  if shows.length > 20
    shows.each do |show|
      @client.query("UPDATE #{$tv_shows} WHERE tvrage_id = #{show[:tvr_id]} SET flagged='0', flag='';")
    end
    puts "Removed flag: #{flag}"
    flags[flag].delete!
  end
end

output_file_path = 'caramcc_sort_flags.json'

File.open(output_file_path, 'a') { |file| file.write(JSON.pretty_generate(flags)) }