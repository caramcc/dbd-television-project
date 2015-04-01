require 'net/http'
require 'json'
require 'mysql2'

@table = 'caramcc_tv_shows'
@database = 'caramcc_dbd_project'

@client = Mysql2::Client.new(:host => "localhost", :username => "root")

@client.query("USE #{@database}")

# Example 4
# I want to determine which languages a given TV Show was broadcast in.

tv_show = 'Breaking Bad'

result = @client.query("SELECT * FROM #{@table} WHERE actors LIKE '%#{tv_show}%';")

result.each do |row|
  puts row['show_title']
end