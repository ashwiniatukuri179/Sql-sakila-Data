-- Use the zybooksdb database
USE zybooksdb;

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Drop the dependent tables if they exist
DROP TABLE IF EXISTS film_actor;
DROP TABLE IF EXISTS film_category;
DROP TABLE IF EXISTS inventory;

-- Drop the main tables if they exist
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS film;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Create table actor
CREATE TABLE actor (
  actor_id SMALLINT UNSIGNED NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id),
  KEY idx_actor_last_name (last_name)
);

-- Create table film
CREATE TABLE film (
  film_id SMALLINT UNSIGNED NOT NULL,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEAR DEFAULT NULL,
  language_id TINYINT UNSIGNED NOT NULL,
  original_language_id TINYINT UNSIGNED DEFAULT NULL,
  rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT UNSIGNED DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  special_features SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id)
);

-- Create table film_actor
CREATE TABLE film_actor (
  actor_id SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  film_id SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id, film_id),
  KEY idx_fk_film_id (film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Load data into actor table
LOAD DATA INFILE '/usercode/actor.csv' INTO TABLE actor
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

-- Load data into film table
LOAD DATA INFILE '/usercode/film.csv' INTO TABLE film
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

-- Load data into film_actor table, ignoring duplicates
LOAD DATA INFILE '/usercode/film_actor.csv' IGNORE INTO TABLE film_actor
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

-- Explain the SELECT statement
EXPLAIN SELECT last_name, first_name, ROUND(AVG(length), 0) AS average
FROM actor
INNER JOIN film_actor ON film_actor.actor_id = actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
WHERE title = "ALONE TRIP"
GROUP BY last_name, first_name
ORDER BY average;

-- Explain the SELECT statement with title less than "ALONE TRIP"
EXPLAIN SELECT last_name, first_name, ROUND(AVG(length), 0) AS average
FROM actor
INNER JOIN film_actor ON film_actor.actor_id = actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
WHERE title < "ALONE TRIP"
GROUP BY last_name, first_name
ORDER BY average;

-- Explain the SELECT statement with title greater than "ALONE TRIP"
EXPLAIN SELECT last_name, first_name, ROUND(AVG(length), 0) AS average
FROM actor
INNER JOIN film_actor ON film_actor.actor_id = actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
WHERE title > "ALONE TRIP"
GROUP BY last_name, first_name
ORDER BY average;