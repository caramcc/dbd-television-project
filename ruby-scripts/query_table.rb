require 'net/http'
require "uri"
require 'json'
# require 'active_support'
require 'mysql2'

@table = 'caramcc_tv_shows'

# def load_data
#   all_data = []
#   Dir.entries('output-data2').drop(2).each do |file_path|
#     File.open(File.join('output-data2', file_path), "r") do |f|
#       f.each_line do |line|
#         all_data.push JSON.parse(line)
#       end
#     end
#   end
#   all_data
# end

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE caramcc_dbd_project")

# result = @client.query("SELECT * FROM #{@table}")

# result.each do |row|
#   puts row["show_title"]
# end

show_title = ARGV[0]
show_network = ARGV[1]

result = @client.query("SELECT * FROM #{@table} WHERE show_title LIKE '%#{show_title}%' AND network LIKE '%#{show_network}%';")

result.each do |row|
 puts row['show_title']
end