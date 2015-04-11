# Assignment 4
- Cara McCormack `@carammcc`


# Normal Form Checks for Tables

## Table: `caramcc_tv_shows`

### SQL

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
  FOREIGN KEY (network_name) REFERENCES caramcc_networks (network_name)
);
```

### 1NF

 - Table has a Primary Key: `show_id`
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key


## Table: `caramcc_networks`

### SQL

```
CREATE TABLE IF NOT EXISTS caramcc_networks (
  network_name varchar(255) NOT NULL DEFAULT '',
  network_twitter_id varchar(63),
  PRIMARY KEY (network_name)
);
```

### 1NF

 - Table has a Primary Key: `network_name`
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key




## Table: `caramcc_actors`

### SQL

```
CREATE TABLE IF NOT EXISTS caramcc_actors (
  actor_id int(11) NOT NULL AUTO_INCREMENT,
  actor_name varchar(255) NOT NULL DEFAULT '',
  actor_twitter_id varchar(63),
  PRIMARY KEY (actor_id)
);
```

### 1NF

 - Table has a Primary Key: `actor_id`
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key




## Table: `caramcc_creators`

### SQL

```
CREATE TABLE IF NOT EXISTS caramcc_creators (
  creator_id int(11) NOT NULL AUTO_INCREMENT,
  creator_name varchar(255) NOT NULL DEFAULT '',
  creator_twitter_id varchar(63),
  PRIMARY KEY (creator_id)
);
```

### 1NF

 - Table has a Primary Key: `creator_id`
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key




## Table: `caramcc_`

### SQL

```
```

### 1NF

 - Table has a Primary Key: `id`
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key


## Map Table: `caramcc_`

### SQL

```
```

### 1NF

 - ~Table has a Primary Key~ Map table
 - Values of each column are atomic
 - No repeating groups: no columns

### 2NF

 - No partial dependencies
 - No calculated data

### 3NF

 - All fields depend on the primary key
