require 'mysql2'
require 'json'

require_relative 'constants.rb'

# run once to move listed data into own table



@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")


def normalize_genres(show)

end

def normalize_languages(show)

end

def map_actors(show)

end

def map_creators(show)

end

def add_networks(show)

end


# @client.query("DROP TABLE #{@table}")

