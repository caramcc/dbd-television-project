require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 4
# I want to determine which languages a given TV Show was broadcast in.

tv_show = 'Breaking Bad'


@client.query("CREATE OR REPLACE VIEW caramcc_all_show_languages
  AS
  SELECT sl.*, s.show_title
  FROM #{$tv_shows} s
  JOIN #{$show_languages} sl ON sl.show_id = s.show_id")

result = @client.query("SELECT language
FROM caramcc_all_show_languages
WHERE show_title LIKE '#{tv_show}';")

result.each do |row|
  puts row['language']
end