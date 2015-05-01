require 'json'
require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)
@client.query("USE #{$db_name}")


updates = @client.query("SELECT update_id FROM #{$updates} ORDER BY update_unix_time DESC LIMIT 1;")

has_updated = false

updates.each do |update|
  if update
    has_updated = true
  end
end

unless has_updated
  @client.query("INSERT INTO #{$updates} (update_unix_time) VALUES ('#{$first_update}')")
end
