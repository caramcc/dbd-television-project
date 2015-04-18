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

twitter users who have tweeted the most similar shows to you (limit 10?)

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

## Question 7 (VIII)
_"I am hiring in my team. Does Twitter have anyone who would be interested?"_
select actor twitter handles where actor tweets contain the words 'job', 'gig', 'casting', 'hire'

### View

```
CREATE OR REPLACE VIEW caramcc_actors_most_recent_shows
  AS
  SELECT a.*, s.start_date, s.show_title FROM caramcc_tv_shows s
  JOIN caramcc_show_actors sa ON sa.show_id = s.show_id
  JOIN caramcc_actors a ON a.actor_id = sa.actor_id
```

### Query

```
SELECT show_title FROM caramcc_actors_most_recent_shows
  WHERE actor_name LIKE 'Hugh Laurie'
  ORDER BY start_date DESC LIMIT 1;
```

### Result:

_House_

## Use Case 2

_"I want to determine which is the lowest-rated TV Show made by a given Creator."_

### View

```
"CREATE OR REPLACE VIEW caramcc_creator_show_ratings
AS
SELECT c.creator_name, s.imdb_rating, s.show_title
FROM caramcc_tv_shows s
JOIN caramcc_show_creators sc ON sc.show_id = s.show_id
JOIN caramcc_creators c ON c.creator_id = sc.creator_id"
```

### Query

```
"SELECT imdb_rating, show_title
FROM caramcc_creator_show_ratings
WHERE creator_name LIKE 'J.J. Abrams'
ORDER BY imdb_rating ASC LIMIT 1"
```

### Result:

_Undercovers_

## Use Case 3

_"I want to determine which genres a given Actor appears in most frequently."_

### View

```
"CREATE OR REPLACE VIEW caramcc_actor_genre_frequency
  AS
  SELECT sg.genre, a.actor_name
  FROM caramcc_actors a
  JOIN caramcc_show_actors sa ON a.actor_id = sa.actor_id
  JOIN caramcc_tv_shows s ON sa.show_id = s.show_id
  JOIN caramcc_show_genres sg ON s.show_id = sg.show_id"
```

### Query

```
"SELECT MAX(genre)
FROM caramcc_actor_genre_frequency
WHERE actor_name LIKE 'Hugh Laurie'"
```

### Result:

_Sketch/Improv_

## Use Case 4

_"I want to determine which languages a given TV Show was broadcast in."_

### View

```
"CREATE OR REPLACE VIEW caramcc_all_show_languages
  AS
  SELECT sl.*, s.show_title
  FROM caramcc_tv_shows s
  JOIN caramcc_show_languages sl ON sl.show_id = s.show_id"
```

### Query

```
"SELECT language
FROM caramcc_all_show_languages
WHERE show_title LIKE 'Breaking Bad';"
```

### Result:

_English
 German
 Persian
 Romanian
 Spanish_

## Use Case 5

_"I want to determine which TV Show made by a given Creator had the most seasons."_

### View

```
"CREATE OR REPLACE VIEW caramcc_creator_show_seasons
AS
SELECT c.*, s.start_date, s.end_date, s.show_title
FROM caramcc_tv_shows s
JOIN caramcc_show_creators sc ON sc.show_id = s.show_id
JOIN caramcc_creators c ON c.creator_id = sc.creator_id"
```

### Query

```
"SELECT show_title
FROM caramcc_creator_show_seasons
WHERE creator_name LIKE 'J.J. Abrams'
ORDER BY DATEDIFF(start_date, end_date ) ASC LIMIT 1;"
```

### Result:

_Lost_

## Use Case 6

_"I want to determine the Network that has aired the most TV Shows in the United States."_

### Query

```
"SELECT MAX(network_name) FROM caramcc_tv_shows
WHERE country LIKE 'US' OR country LIKE 'USA' OR country LIKE 'United States%'
LIMIT 1"
```

### Result:

_Z LIVING_

## Use Case 7

_"I want to determine the average IMDB rating for shows aired on the network HBO."_

### Query

```
"SELECT AVG(imdb_rating) FROM caramcc_tv_shows
WHERE network_name LIKE 'HBO' AND imdb_rating > 0 "
```

### Result:

_7.6255556_

## Use Case 8

_"I want to determine the titles of all the shows broadcast on NBC."_

### Query

```
"SELECT show_title FROM caramcc_tv_shows WHERE network_name LIKE 'NBC'
```

### Result:

_(long list, results omitted)_

## Use Case 9

_"I want to determine how many TV Shows a given Creator has made."_

### View

```
"CREATE OR REPLACE VIEW caramcc_creator_show_count
AS
SELECT c.creator_name
FROM caramcc_show_creators sc
JOIN caramcc_creators c ON c.creator_id = sc.creator_id"
```

### Query

```
"SELECT COUNT(*)
FROM caramcc_creator_show_count
WHERE creator_name LIKE 'J.J. Abrams' "
```

### Result:

_5_

## Use Case 10

_"I want to determine which TV Show broadcast in the UK has received the most IMDB votes."_


### Query

```
"SELECT show_title FROM caramcc_tv_shows
WHERE country LIKE 'UK'
ORDER BY imdb_votes DESC LIMIT 1"
```

### Result:

_Sherlock_