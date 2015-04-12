require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 5
# I want to determine which TV Show made by a given Creator had the most seasons.

creator = 'J.J. Abrams'

@client.query("CREATE OR REPLACE VIEW caramcc_creator_show_seasons
AS
SELECT c.*, s.start_date, s.end_date, s.show_title
FROM #{$tv_shows} s
JOIN #{$show_creators} sc ON sc.show_id = s.show_id
JOIN #{$creators} c ON c.creator_id = sc.creator_id")

result = @client.query("SELECT show_title
FROM caramcc_creator_show_seasons
WHERE creator_name LIKE '#{creator}'
ORDER BY DATEDIFF(start_date, end_date ) ASC LIMIT 1;")

result.each do |row|
  puts row['show_title']
end