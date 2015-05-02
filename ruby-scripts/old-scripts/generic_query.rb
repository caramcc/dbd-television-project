# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require "uri"
require 'json'
# require 'active_support'
require 'mysql2'

@table = 'caramcc_tv_shows'


@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE caramcc_dbd_project")

result = @client.query("SELECT * FROM #{@table} WHERE flagged=1;")

output = {}
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


File.open(output_file_path, 'a') { |file| file.write(JSON.pretty_generate(output)) }