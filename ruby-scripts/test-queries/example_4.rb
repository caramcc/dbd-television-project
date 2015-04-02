require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 4
# I want to determine which languages a given TV Show was broadcast in.

tv_show = 'Breaking Bad'

result = @client.query("SELECT sl.*, s.show_id
FROM #{$tv_shows} s
JOIN #{$show_languages} sl ON sl.show_id = s.show_id
WHERE show_title LIKE '#{tv_show}';")

result.each do |row|
  puts row['language']
end