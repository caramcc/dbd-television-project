require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

ARGV.each do |show_id|
  @client.query("DELETE FROM #{$tv_shows} WHERE show_id = #{show_id}")
end