require 'net/http'
require 'json'
require 'mysql2'

@table = 'caramcc_tv_shows'
@database = 'caramcc_dbd_project'

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE #{@database}")

# Example 2
# I want to determine which is the lowest-rated TV Show made by a given Creator.

creator = 'J.J. Abrams'

result = @client.query("SELECT * FROM #{@table} WHERE actors LIKE '%#{creator}%';")

result.each do |row|
  puts row['show_title']
end