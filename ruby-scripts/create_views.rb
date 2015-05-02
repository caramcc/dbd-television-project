# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

require 'mysql2'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("CREATE DATABASE IF NOT EXISTS #{$db_name}")
@client.query("USE #{$db_name}")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_genres
  AS
  SELECT sg.genre, s.*
  FROM #{$tv_shows} s
  JOIN #{$show_genres} sg ON sg.show_id = s.show_id")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_languages
  AS
  SELECT sl.language, s.*
  FROM #{$tv_shows} s
  JOIN #{$show_languages} sl ON sl.show_id = s.show_id")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_creators
AS
SELECT c.*, s.*
FROM #{$tv_shows} s
JOIN #{$show_creators} sc ON sc.show_id = s.show_id
JOIN #{$creators} c ON c.creator_id = sc.creator_id")

@client.query("CREATE OR REPLACE VIEW caramcc_actor_genres
  AS
  SELECT sg.genre, a.actor_name
  FROM #{$actors} a
  JOIN #{$show_actors} sa ON a.actor_id = sa.actor_id
  JOIN #{$tv_shows} s ON sa.show_id = s.show_id
  JOIN #{$show_genres} sg ON s.show_id = sg.show_id")

@client.query("CREATE OR REPLACE VIEW caramcc_creator_genres
  AS
  SELECT sg.genre, c.creator_name
  FROM #{$creators} c
  JOIN #{"#{$show_creators}"} sc ON c.creator_id = sc.creator_id
  JOIN #{$tv_shows} s ON sc.show_id = s.show_id
  JOIN #{$show_genres} sg ON s.show_id = sg.show_id")

@client.query("CREATE OR REPLACE VIEW caramcc_all_show_actors
  AS
  SELECT a.*, s.start_date, s.show_title FROM #{$tv_shows} s
  JOIN #{$show_actors} sa ON sa.show_id = s.show_id
  JOIN #{$actors} a ON a.actor_id = sa.actor_id")