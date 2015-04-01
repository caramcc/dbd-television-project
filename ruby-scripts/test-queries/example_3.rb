require 'net/http'
require 'json'
require 'mysql2'

@table = 'caramcc_tv_shows'
@database = 'caramcc_dbd_project'

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE #{@database}")

# Example 3
# I want to determine which genres a given Actor appears in most frequently.

actor = 'Hugh Laurie'

result = @client.query("SELECT * FROM #{@table} WHERE actors LIKE '%#{actor}%';")

result.each do |row|
  puts row['show_title']
end