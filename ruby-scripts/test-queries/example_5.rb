require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 5
# I want to determine which TV Show made by a given Creator had the most seasons.

creator = 'J.J. Abrams'

result = @client.query("SELECT c.*, s.start_date, s.end_date, s.show_title, DATEDIFF(s.start_date, s.end_date )
FROM #{$tv_shows} s
JOIN #{$show_creators} sc ON sc.show_id = s.show_id
JOIN #{$creators} c ON c.creator_id = sc.creator_id
WHERE creator_name LIKE '%#{creator}%'
ORDER BY DATEDIFF(s.start_date, s.end_date ) ASC;")

result.each do |row|
  puts row['show_title']
end