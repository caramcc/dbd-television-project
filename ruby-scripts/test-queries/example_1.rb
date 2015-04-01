require 'net/http'
require 'json'
require 'mysql2'

@table = 'caramcc_tv_shows'
@database = 'caramcc_dbd_project'

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE #{@database}")

# Example 1
# I want to determine the TV Show a given Actor has appeared in most recently.

actor = 'Hugh Laurie'
creator = 'J.J. Abrams'
tv_show = 'Breaking Bad'

result = @client.query("SELECT * FROM #{@table} WHERE actors LIKE '%#{actor}%';")

result.each do |row|
  puts row['show_title']
end