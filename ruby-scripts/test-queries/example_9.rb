require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 9
# I want to determine how many TV Shows a given Creator has made.

creator = 'J.J. Abrams'

result = @client.query("SELECT COUNT(*)
FROM #{$show_creators} sc
JOIN #{$creators} c ON c.creator_id = sc.creator_id
WHERE creator_name LIKE '#{creator}' ")

result.each do |row|
  puts row['COUNT(*)']
end