require 'net/http'
require 'json'
require 'mysql2'

@table = 'caramcc_tv_shows'
@database = 'caramcc_dbd_project'

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE #{@database}")

# Example 5
# I want to determine which TV Show made by a given Creator had the most seasons.

creator = 'J.J. Abrams'

result = @client.query("SELECT * FROM #{@table} WHERE actors LIKE '%#{creator}%';")

result.each do |row|
  puts row['show_title']
end