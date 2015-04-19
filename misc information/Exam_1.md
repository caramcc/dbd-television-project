# Exam 1
- Cara McCormack `@carammcc` (working alone)
- [Github Repo for project](https://github.com/caramcc/dbd-television-project)
- [Latest Commit Hash](https://github.com/caramcc/dbd-television-project/commit/5bf359a87ab65e433c9862b07dad5a1e87cd25fe)

# SQL for Database Schema

```
CREATE TABLE IF NOT EXISTS caramcc_tv_shows (
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
  FOREIGN KEY (network_name) REFERENCES caramcc_networks(network_name)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_networks (
  network_name varchar(255) NOT NULL DEFAULT '',
  network_twitter_id varchar(63),
  PRIMARY KEY (network_name)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_actors (
  actor_id int(11) NOT NULL AUTO_INCREMENT,
  actor_name varchar(255) NOT NULL DEFAULT '',
  actor_twitter_id varchar(63),
  PRIMARY KEY (actor_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_creators (
  creator_id int(11) NOT NULL AUTO_INCREMENT,
  creator_name varchar(255) NOT NULL DEFAULT '',
  creator_twitter_id varchar(63),
  PRIMARY KEY (creator_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_show_actors (
  show_id int(11) NOT NULL,
  actor_id int(11) NOT NULL,
  PRIMARY KEY (show_id, actor_id),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id),
  FOREIGN KEY (actor_id) REFERENCES caramcc_actors(actor_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_show_creators (
  show_id int(11) NOT NULL,
  creator_id int(11) NOT NULL,
  PRIMARY KEY (show_id, creator_id),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id),
  FOREIGN KEY (creator_id) REFERENCES caramcc_creators(creator_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_show_genres (
  show_id int(11) NOT NULL,
  genre varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, genre),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_show_airdays (
  show_id int(11) NOT NULL,
  airday varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, airday),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id)
);
```

```
CREATE TABLE IF NOT EXISTS caramcc_show_alt_titles (
  show_id int(11) NOT NULL,
  alt_title varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, alt_title),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id)
);
```


```
CREATE TABLE IF NOT EXISTS caramcc_show_languages (
  show_id int(11) NOT NULL,
  language varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (show_id, language),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows(show_id)
);
```

### I used the provided Exam1 Twitter Schema

```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tags (
  tag_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  tag varchar(255) NOT NULL DEFAULT '',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  created_at datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (tag_id,tag)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=33 ;
```

```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tag_Category (
  category_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  category varchar(255) DEFAULT NULL,
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (category_id)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=33 ;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tag_Category_Map (
  category_id bigint(20) unsigned NOT NULL DEFAULT '0',
  tag_id bigint(20) unsigned NOT NULL DEFAULT '0',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (category_id,tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tweets (
  tweet_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  from_user_id bigint(20) unsigned NOT NULL DEFAULT '0',
  tweet varchar(255) DEFAULT NULL,
  geo varchar(255) NOT NULL,
  created_at datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (tweet_id),
  KEY tweet (tweet)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=29 ;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tweets_Tag_Map (
  tweet_id bigint(20) unsigned NOT NULL DEFAULT '0',
  tag_id bigint(20) unsigned NOT NULL DEFAULT '0',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (tweet_id,tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Tweets_Url_Map (
  tweet_id bigint(20) unsigned NOT NULL DEFAULT '0',
  url_id bigint(20) unsigned NOT NULL DEFAULT '0',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (tweet_id,url_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Urls (
  url_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  url varchar(555) NOT NULL DEFAULT '',
  verified tinyint(4) NOT NULL DEFAULT '0',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (url_id),
  KEY tag (url(333))
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=29 ;
```
```
CREATE TABLE IF NOT EXISTS Exam1_Twitter_Users (
  user_id bigint(20) unsigned NOT NULL DEFAULT '0',
  name varchar(255) NOT NULL DEFAULT '''''',
  screen_name varchar(255) NOT NULL DEFAULT '''''',
  location varchar(255) NOT NULL DEFAULT '''''',
  latitude double NOT NULL,
  longitude double NOT NULL,
  created_at datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  last_update datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  followers_count int(11) NOT NULL DEFAULT '0',
  verified tinyint(4) NOT NULL DEFAULT '0',
  geo_enabled tinyint(4) NOT NULL DEFAULT '0',
  description text NOT NULL,
  time_zone varchar(255) NOT NULL DEFAULT '',
  friends_count int(11) unsigned NOT NULL DEFAULT '0',
  statuses_count int(11) unsigned NOT NULL DEFAULT '0',
  tweet_freq float NOT NULL DEFAULT '0',
  bot_count int(11) unsigned NOT NULL DEFAULT '0',
  protected tinyint(4) NOT NULL DEFAULT '0',
  utc_offset int(11) NOT NULL DEFAULT '0',
  notifications varchar(255) NOT NULL DEFAULT '''''',
  lang char(2) NOT NULL DEFAULT '''''',
  following varchar(255) NOT NULL DEFAULT '''''',
  favourites_count int(10) unsigned NOT NULL DEFAULT '0',
  url varchar(255) NOT NULL DEFAULT '''''',
  contributors_enabled tinyint(4) NOT NULL DEFAULT '0',
  is_translator tinyint(4) NOT NULL DEFAULT '0',
  listed_count int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (user_id),
  KEY screen_name (screen_name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

### I also added a table to the twitter schema:

```
CREATE TABLE IF NOT EXISTS caramcc_user_shows_followed (
  user_id bigint(20) unsigned NOT NULL DEFAULT '0',
  show_id int(11) NOT NULL,
  PRIMARY KEY (user_id, show_id),
  FOREIGN KEY (user_id) REFERENCES Exam1_Twitter_Users (user_id),
  FOREIGN KEY (show_id) REFERENCES caramcc_tv_shows (show_id),
);
```


## Question 1

_"What are the top trends in your domain on Twitter?"_

thoughts: count other tags in tweets tagged TV shows, known twitter handles

I created a View representing  to handle this case:

```
"CREATE OR REPLACE VIEW `caramcc_Exam1_tv_tweets`
AS
SELECT ttmap.tag_id, tweets.*
FROM Exam1_Twitter_Tweets tweets
JOIN Exam1_Twitter_Tweets_Tag_Map ttmap ON tweets.tweet_id = ttmap.tweet_id
JOIN Exam1_Twitter_Tag_Category_Map tcmap ON ttmap.tag_id = tcmap.tag_id
JOIN Exam1_Twitter_Tag_Category tc ON tcmap.category_id = tc.category_id
  AND (tc.category LIKE '%television%" OR tc.category LIKE '%tv%')"
```

Then created a query to determine what tags within the TV Show domain have been updated in the last month, and order them by the ones that appear most often.


```
"SELECT tag
FROM Exam1_Twitter_Tags tags
JOIN caramcc_Exam1_tv_tweets tweets ON tweets.tag_id = tags.tag_id
WHERE last_update >= DATE_SUB(CURDATE(), INTERVAL 1 month)
ORDER BY COUNT(*) DESC LIMIT 20"
```



## Question 2

_"Who should I be following?"_

twitter users who have tweeted the most similar shows to you

```
"SELECT screen_name FROM Exam1_Twitter_Users
WHERE
```

## Question 3 (IV)

_"What are the most popular things? (What are the most popular shows?)"_

To answer this question, I have defined 'popular' as TV Shows that are regarded favorably (IMDB Rating of at least 7.0) and have the most votes on IMDB.
Popularity and IMDB ratings seem to correlate, as the top 20 shows ordered by number of votes on IMDB all have a rating of at least 7.0.

```
"SELECT show_title FROM caramcc_tv_shows WHERE imdb_rating > 7.0
ORDER BY imdb_votes DESC LIMIT 20;"
```

## Question 4 (V)

_"What are the most similar things? (What are the most similar shows?)"_
twitter users who follow one show also following another show
shows by genre


## Question 5 (VI)

_"Who is the best person at something? (What TV Network creates the best content?)"_

I determine the best content using IMDB rating.
In order to make sure that the network has consistent quality, I have filtered out networks that have 20 or fewer TV shows, as well as networks that have received 2000 or fewer votes on IMDB per show, on average.
In order to make sure that TV Shows that lack network data are excluded, I filtered out the network `''`.
In order to make sure that shows that lack IMDB data are excluded, I filtered out shows with an IMDB rating of 0.
I have decided to return the 20 best networks based on this criteria.

```
"SELECT network_name, avg_rating
FROM (
SELECT network_name, AVG(imdb_rating) as avg_rating, AVG(imdb_votes) as avg_votes FROM caramcc_tv_shows
WHERE imdb_rating > 0.0 AND network_name NOT LIKE ''
GROUP BY network_name
HAVING COUNT(*) > 20 AND avg_votes > 2000) t
ORDER BY avg_rating DESC LIMIT 20"
```

## Question 6 (VII)
_"What thing should I buy? (What TV Show should I watch?)"_
what other things do most people who watch the shows I watch also watch?

what highly-rated shows have at least one of the same genres of the shows that I have tweeted about?

### Views

```
"CREATE OR REPLACE VIEW caramcc_all_show_genres
  AS
  SELECT sg.*, s.*
  FROM caramcc_tv_shows s
  JOIN caramcc_show_genres sg ON sg.show_id = s.show_id"
```

```
"CREATE OR REPLACE VIEW caramcc_all_user_genres
  AS
  SELECT sg.genre, u.user_id
  FROM caramcc_user_shows u
  JOIN caramcc_tv_shows s ON u.show_id = s.show_id
  JOIN caramcc_show_genres sg ON s.show_id = sg.show_id"
```

(Assume we are given a user_id, #{user_id} to search for)

### Query

```
"SELECT show_title FROM caramcc_tv_shows
WHERE imdb_rating >= 9.0 AND imdb_votes > 2000
AND EXISTS (
  SELECT genre FROM caramcc_all_show_genres
  WHERE genre LIKE (
    SELECT MAX(genre) FROM caramcc_all_user_genres
    WHERE user_id = #{user_id}
    ORDER BY COUNT(*) LIMIT 1 )
```

## Question 7 (VIII)
_"I am hiring in my team. Does Twitter have anyone who would be interested?"_

In order to determine what actors on twitter might be looking for a job, I search through all known actor twitter handles for tweets they've written containing the words:
'job', 'gig', 'casting', 'hire', 'employ', and 'opportunit' (for opportunity/ies)

### View

```
"CREATE OR REPLACE VIEW caramcc_actor_tweets
  AS
  SELECT a.actor_name
  FROM caramcc_actors a
  JOIN Exam1_Twitter_Users u ON a.actor_twitter_id LIKE u.screen_name
  JOIN Exam1_Twitter_Tweets t ON u.user_id = t.from_user_id"
```

### Query

```
"SELECT actor_name
FROM caramcc_actor_tweets
WHERE tweet LIKE '%job%'
OR tweet LIKE '%gig%'
OR tweet LIKE '%casting%'
OR tweet LIKE '%hire%'
OR tweet LIKE '%employ%'
OR tweet LIKE '%opportunit%'
"
```

