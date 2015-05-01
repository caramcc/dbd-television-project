require 'mysql2'
require 'json'

require_relative 'constants.rb'

@client = Mysql2::Client.new(:host => $host, :username => $username, :password => $password)

@client.query("CREATE DATABASE IF NOT EXISTS #{$db_name}")
@client.query("USE #{$db_name}")

@client.query("DROP TABLE #{$show_alt_titles}")
@client.query("DROP TABLE #{$show_actors}")
@client.query("DROP TABLE #{$show_creators}")
@client.query("DROP TABLE #{$show_genres}")
@client.query("DROP TABLE #{$show_languages}")
@client.query("DROP TABLE #{$show_airdays}")
@client.query("DROP TABLE #{$tv_shows}")
@client.query("DROP TABLE #{$actors}")
@client.query("DROP TABLE #{$creators}")
@client.query("DROP TABLE #{$networks}")
@client.query("DROP TABLE #{$updates}")


@client.query("CREATE TABLE IF NOT EXISTS #{$networks} (
  network_name varchar(255) NOT NULL DEFAULT '' UNIQUE,
  network_twitter_id varchar(63),
  PRIMARY KEY (network_name)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$tv_shows} (
  show_id int(11) NOT NULL AUTO_INCREMENT,
  show_title varchar(255) NOT NULL DEFAULT '',
  country varchar(255) NOT NULL DEFAULT '',
  start_date date NOT NULL DEFAULT '1000-01-01',
  end_date date,
  content_rating varchar(11) NOT NULL DEFAULT '',
  classification varchar(255) NOT NULL DEFAULT '',
  runtime int(11) NOT NULL DEFAULT '0',
  network_name varchar(255) NOT NULL DEFAULT '',
  airtime varchar(11) NOT NULL DEFAULT '',
  timezone varchar(63) NOT NULL DEFAULT '',
  plot_summary text(8191) NOT NULL,
  award_nominations int(11) NOT NULL DEFAULT '0',
  award_wins int(11) NOT NULL DEFAULT '0',
  imdb_rating float(8,3) NOT NULL DEFAULT '0',
  imdb_votes int(11) NOT NULL DEFAULT '0',
  imdb_id varchar(11) NOT NULL DEFAULT '',
  tvrage_id int(11) NOT NULL DEFAULT '0',
  show_twitter_id varchar(33) NOT NULL DEFAULT '',
  flagged tinyint(1) NOT NULL DEFAULT '0',
  flag varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id),
  FOREIGN KEY (network_name) REFERENCES #{$networks}(network_name) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$actors} (
  actor_id int(11) NOT NULL AUTO_INCREMENT,
  actor_name varchar(255) NOT NULL DEFAULT '',
  actor_twitter_id varchar(63),
  PRIMARY KEY (actor_id)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$creators} (
  creator_id int(11) NOT NULL AUTO_INCREMENT,
  creator_name varchar(255) NOT NULL DEFAULT '',
  creator_twitter_id varchar(63),
  PRIMARY KEY (creator_id)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$show_actors} (
  show_id int(11) NOT NULL,
  actor_id int(11) NOT NULL,
  PRIMARY KEY (show_id, actor_id),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES #{$actors}(actor_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")


@client.query("CREATE TABLE IF NOT EXISTS #{$show_creators} (
  show_id int(11) NOT NULL,
  creator_id int(11) NOT NULL,
  PRIMARY KEY (show_id, creator_id),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE,
  FOREIGN KEY (creator_id) REFERENCES #{$creators}(creator_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$show_genres} (
  show_id int(11) NOT NULL,
  genre varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, genre),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$show_airdays} (
  show_id int(11) NOT NULL,
  airday varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, airday),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$show_alt_titles} (
  show_id int(11) NOT NULL,
  alt_title varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, alt_title),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$show_languages} (
  show_id int(11) NOT NULL,
  language varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, language),
  FOREIGN KEY (show_id) REFERENCES #{$tv_shows}(show_id) ON DELETE CASCADE
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")

@client.query("CREATE TABLE IF NOT EXISTS #{$updates} (
  update_id int(11) NOT NULL AUTO_INCREMENT,
  update_unix_time int(33) NOT NULL DEFAULT 0,
  PRIMARY KEY (update_id)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;")