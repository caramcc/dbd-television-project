require 'mysql2'
require 'json'

require_relative 'constants.rb'

# run once to move listed data into own table

@table = 'caramcc_tv_shows'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE caramcc_dbd_project")


def normalize_genres

end