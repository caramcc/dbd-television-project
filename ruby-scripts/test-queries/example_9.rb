# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'net/http'
require 'json'
require 'mysql2'

require_relative '../constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

# Example 9
# I want to determine how many TV Shows a given Creator has made.

creator = 'J.J. Abrams'

@client.query("CREATE OR REPLACE VIEW caramcc_creator_show_count
AS
SELECT c.creator_name
FROM #{$show_creators} sc
JOIN #{$creators} c ON c.creator_id = sc.creator_id")

result = @client.query("SELECT COUNT(*)
FROM caramcc_creator_show_count
WHERE creator_name LIKE '#{creator}' ")

result.each do |row|
  puts row['COUNT(*)']
end