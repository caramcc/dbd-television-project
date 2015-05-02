# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'mysql2'
require 'json'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("USE #{$db_name}")

#
# alter = [
# "ALTER TABLE #{$show_actors}
#   DROP FOREIGN KEY caramcc_show_actors_ibfk_1","
# ALTER TABLE #{$show_actors}
#   ADD CONSTRAINT caramcc_show_actors_ibfk_1_cascade
#   FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_actors}
#   DROP FOREIGN KEY caramcc_show_actors_ibfk_2","
# ALTER TABLE #{$show_actors}
#   ADD CONSTRAINT caramcc_show_actors_ibfk_2_cascade
#   FOREIGN KEY (actor_id) REFERENCES #{$actors}(actor_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_airdays}
#   DROP FOREIGN KEY caramcc_show_airdays_ibfk_1","
# ALTER TABLE #{$show_airdays}
#   ADD CONSTRAINT caramcc_show_airdays_ibfk_1_cascade
#   FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_alt_titles}
#   DROP FOREIGN KEY caramcc_show_alt_titles_ibfk_1","
# ALTER TABLE #{$show_alt_titles}
#   ADD CONSTRAINT caramcc_show_alt_titles_ibfk_1_cascade
#   FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_genres}
#   DROP FOREIGN KEY caramcc_show_genres_ibfk_1","
# ALTER TABLE #{$show_genres}
#   ADD CONSTRAINT caramcc_show_genres_ibfk_1_cascade
#   FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_creators}
#   DROP FOREIGN KEY caramcc_show_creators_ibfk_1","
# ALTER TABLE #{$show_creators}
#   ADD CONSTRAINT caramcc_show_creators_ibfk_1_cascade
#   FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$show_creators}
#   DROP FOREIGN KEY caramcc_show_creators_ibfk_2","
# ALTER TABLE #{$show_creators}
#   ADD CONSTRAINT caramcc_show_creators_ibfk_2_cascade
#   FOREIGN KEY (creator_id) REFERENCES #{$creators}(creator_id) ON DELETE CASCADE;",
# "ALTER TABLE #{$tv_shows}
#   DROP FOREIGN KEY caramcc_tv_shows2_ibfk_1","
# ALTER TABLE #{$tv_shows}
#   ADD CONSTRAINT caramcc_tv_shows2_ibfk_1_cascade
#   FOREIGN KEY (network_name) REFERENCES #{$networks}(network_name) ON DELETE CASCADE;"
# ]

alter = [
    "ALTER TABLE #{$show_languages}
  DROP FOREIGN KEY caramcc_show_languages_ibfk_1","
ALTER TABLE #{$show_languages}
  ADD CONSTRAINT caramcc_show_languages_ibfk_1_cascade
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE;"
]

alter.each do |q|
  @client.query(q)
end