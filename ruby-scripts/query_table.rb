require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# result = @client.query("SELECT * FROM #{@table}")

# result.each do |row|
#   puts row["show_title"]
# end

show_title = ARGV[0]
show_network = ARGV[1]

result = @client.query("SELECT * FROM #{$tv_shows} WHERE show_title LIKE '%#{show_title}%' AND network LIKE '%#{show_network}%';")

result.each do |row|
 puts row
end