/* 
In this first coding exercise, you will use SELECT statements to retrieve columns from a database table. 
You'll be working with the eurovision table, which contains data relating to individual country performance at the Eurovision Song Contest from 1998 to 2012.
*/
-- Select the points column
SELECT 
  points 
FROM 
  eurovision;
  
-- Limit the number of rows returned
SELECT 
  TOP (50) points 
FROM 
  eurovision;
  
-- Return unique countries and use an alias
SELECT 
  DISTINCT country as unique_country 
FROM 
  eurovision;
  
-- Return all columns, restricting the percent of rows returned
SELECT 
  TOP (50) PERCENT * 
FROM 
  eurovision;
  
/*
In this exercise, you'll practice the use of ORDER BY using the grid dataset.
It contains a subset of wider publicly available information on US power outages.
Some of the main columns include:
description: The reason/ cause of the outage.
nerc_region: The North American Electricity Reliability Corporation was formed to ensure the reliability of the grid and comprises several regional entities).
demand_loss_mw: How much energy was not transmitted/consumed during the outage.
*/
-- Select the first 5 rows from the specified columns
SELECT 
  TOP (5) description, 
  event_date 
FROM 
  grid 
-- Order your results by the event_date column
ORDER BY 
  event_date;
  
-- Select the top 20 rows from description, nerc_region and event_date
SELECT 
  TOP (20) description,
  nerc_region,
  event_date
FROM 
  grid 
-- Order by nerc_region, affected_customers & event_date
-- Event_date should be in descending order
ORDER BY
  nerc_region,
  affected_customers,
  event_date DESC;
  
-- Select description and event_year
SELECT 
  description, 
  event_year 
FROM 
  grid 
-- Filter the results
WHERE 
  description = 'Vandalism';

-- Select description and affected customers
SELECT 
  nerc_region, 
  demand_loss_mw 
FROM 
  grid 
-- Retrieve rows where the event_date was the 22nd December, 2013    
WHERE 
  affected_customers >= 500000;
  
-- Select description and affected customers
SELECT 
  description, 
  affected_customers 
FROM 
  grid 
-- Retrieve rows where the event_date was the 22nd December, 2013    
WHERE 
  event_date = '2013-12-22';
  
-- Select description, affected_customers and event date
SELECT 
  description, 
  affected_customers,
  event_date
FROM 
  grid 
  -- The affected_customers column should be >= 50000 and <=150000   
WHERE 
  affected_customers BETWEEN 50000
  AND 150000
   -- Define the order   
ORDER BY 
  event_date DESC;
  
-- Retrieve all columns
SELECT 
    *
FROM
    grid
WHERE
    demand_loss_mw IS NOT NULL;
  
/* 
In this set of exercises, you'll use the songlist table, which contains songs featured on the playlists of 25 classic rock radio stations.
*/

SELECT 
  song, 
  artist, 
  release_year
FROM 
  songlist 
WHERE 
  -- Retrieve records greater than and including 1980
  release_year >= 1980 
  -- Also retrieve records up to and including 1990
  AND release_year <= 1990 
ORDER BY 
  artist, 
  release_year;
  
SELECT 
  artist, 
  release_year, 
  song 
FROM 
  songlist 
  -- Choose the correct artist and specify the release year
WHERE 
  (
    artist LIKE 'B%' 
    AND release_year = 1986
  ) 
  -- Or return all songs released after 1990
  OR release_year > 1990;
  
-- Summing
-- Sum the demand_loss_mw column
SELECT 
  SUM(demand_loss_mw) AS MRO_demand_loss
FROM 
  grid 
WHERE
  -- demand_loss_mw should not contain NULL values
  demand_loss_mw IS NOT NULL 
  -- and nerc_region should be 'MRO';
  AND nerc_region = 'MRO';
  
-- Counting
-- Obtain a count of 'grid_id'
SELECT 
  COUNT(grid_id) AS RFC_count
FROM 
  grid
-- Restrict to rows where the nerc_region is 'RFC'
WHERE
  nerc_region = 'RFC';
  
-- MIN, MAX and AVG
-- Find the minimum number of affected customers
SELECT 
  MIN(affected_customers) AS min_affected_customers
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE
  affected_customers IS NOT NULL;
  
-- Find the maximum number of affected customers
SELECT 
  MAX(affected_customers) AS max_affected_customers 
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE 
  demand_loss_mw IS NOT NULL;
  
-- Find the average number of affected customers
SELECT 
  AVG(affected_customers) AS avg_affected_customers 
FROM 
  grid
-- Only retrieve rows where demand_loss_mw has a value
WHERE 
  demand_loss_mw IS NOT NULL;
  
-- Knowing the length of a string is key to being able to manipulate it further using other functions.
-- Calculate the length of the description column
SELECT 
  LEN (description) AS description_length 
FROM 
  grid;
 
-- Select the first 25 characters from the left of the description column
SELECT 
  LEFT(description, 25) AS first_25_left 
FROM 
  grid;
 
-- Complete the query to find `Weather` within the description column
SELECT 
  description, 
-- You can use CHARINDEX to find a specific character or pattern within a column.
  CHARINDEX('Weather', description) AS start_of_string,
-- Complete the query to find the length of `Weather'
  LEN('Weather') AS length_of_string,
-- Return everything after Weather
  SUBSTRING(
    description, 
    15,  -- Begin counting from the 15th character
    LEN(description)
  ) AS additional_description 
FROM 
  grid
WHERE description LIKE '%Weather%';

-- GROUP BY
-- Select the region column
SELECT 
  nerc_region,
  -- Sum the demand_loss_mw column
  SUM(demand_loss_mw) AS demand_loss
FROM 
  grid
  -- Exclude NULL values of demand_loss
WHERE 
  demand_loss_mw IS NOT NULL
  -- Group the results by nerc_region
GROUP BY
  nerc_region
  -- Order the results in descending order of demand_loss
ORDER BY 
  demand_loss DESC;
  
 /*
 WHERE is used to filter rows before any grouping occurs. 
 Once you have performed a grouping operation, you may want to further restrict the number of rows returned. 
 This is a job for HAVING. 
 */
SELECT 
  nerc_region, 
  SUM (demand_loss_mw) AS demand_loss 
FROM 
  grid 
  -- Remove the WHERE clause
GROUP BY 
  nerc_region 
  -- Enter a new HAVING clause so that the sum of demand_loss_mw is greater than 10000
HAVING 
  SUM(demand_loss_mw) > 10000
ORDER BY 
  demand_loss DESC;
  
SELECT 
  country, 
  COUNT (country) AS country_count, 
  AVG (place) AS avg_place, 
  AVG (points) AS avg_points, 
  MIN (points) AS min_points, 
  MAX (points) AS max_points 
FROM 
  eurovision 
GROUP BY 
  country 
  -- The country column should only contain those with a count greater than 5
HAVING 
  COUNT(country) > 5 
  -- Arrange columns in the correct order
ORDER BY 
  avg_place, 
  avg_points DESC;
  
-- Joining Tables
SELECT 
  track_id,
  name AS track_name,
  title AS album_title
FROM track
  -- Complete the join type and the common joining column
INNER JOIN album on album.album_id = track.album_id;

-- Select album_id and title from album, and name from artist
SELECT 
  album_id,
  title,
  artist.name AS artist
  -- Enter the main source table name
FROM album
  -- Perform the inner join
INNER JOIN artist on album.artist_id = artist.artist_id;

SELECT track_id,
-- Enter the correct table name prefix when retrieving the name column from the track table
  track.name AS track_name,
  title as album_title,
  -- Enter the correct table name prefix when retrieving the name column from the artist table
  artist.name AS artist_name
FROM track
  -- Complete the matching columns to join album with track, and artist with album
INNER JOIN album on album.album_id = track.album_id
INNER JOIN artist on artist.artist_id = album.artist_id;

SELECT 
  album.album_id,
  title,
  album.artist_id,
  artist.name as artist
FROM album
INNER JOIN artist ON album.artist_id = artist.artist_id
-- Perform the correct join type to return matches or NULLS from the track table
LEFT JOIN track on album.album_id = track.album_id
WHERE album.album_id IN (213,214);

/* 
You can write 2 or more SELECT statements and combine the results using UNION. 
For example, you may have two different tables with similar column types. 
If you wanted to combine these into one set of results, you'd use UNION. 
*/
-- Join the UNION
SELECT 
  album_id AS ID,
  title AS description,
  'Album' AS Source
  -- Complete the FROM statement
FROM album
 -- Combine the result set using the relevant keyword
UNION
SELECT 
  artist_id AS ID,
  name AS description,
  'Artist'  AS Source
  -- Complete the FROM statement
FROM artist;

-- Create the table
CREATE TABLE results (
	-- Create track column
	track VARCHAR(200),
    -- Create artist column
	artist VARCHAR(120),
    -- Create album column
	album VARCHAR(160),
	-- Create track_length_mins
	track_length_mins INT,
	);

-- Select all columns from the table
SELECT 
  track, 
  artist, 
  album, 
  track_length_mins 
FROM 
  results;
  
-- Create the table
CREATE TABLE tracks(
  -- Create track column
  track VARCHAR(200), 
  -- Create album column
  album VARCHAR(160), 
  -- Create track_length_mins column
  track_length_mins INT
);
-- Complete the statement to enter the data to the table     
INSERT INTO tracks 
-- Specify the destination columns
(track, album, track_length_mins) 
-- Insert the appropriate values for track, album and track length
VALUES 
  ('Basket Case', 'Dookie', 3);
-- Select all columns from the new table
SELECT 
  * 
FROM 
  tracks;
  
-- Select the album
SELECT 
  title 
FROM 
  album 
WHERE 
  album_id = 213;
-- UPDATE the title of the album
UPDATE 
  album 
SET 
  title = 'Pure Cult: The Best Of The Cult' 
WHERE 
  album_id = 213;
-- Run the query again
SELECT 
  title 
FROM 
  album ;

-- Run the query
SELECT 
  * 
FROM 
  album;
  -- DELETE the record
DELETE FROM 
  album 
WHERE 
  album_id = 1;
  -- Run the query again
SELECT 
  * 
FROM 
  album;

-- Declare the variable @region
DECLARE @region VARCHAR(10)

-- Update the variable value
SET @region = 'RFC'

SELECT description,
       nerc_region,
       demand_loss_mw,
       affected_customers
FROM grid
WHERE nerc_region = @region;

-- Declare your variables
DECLARE @start DATE
DECLARE @stop DATE
DECLARE @affected INT;
-- SET the relevant values for each variable
SET @start = '2014-01-24'
SET @stop  = '2014-07-02'
SET @affected =  5000 ;

SELECT 
  description,
  nerc_region,
  demand_loss_mw,
  affected_customers
FROM 
  grid
-- Specify the date range of the event_date and the value for @affected
WHERE event_date BETWEEN @start AND @stop
AND affected_customers >= @affected;


SELECT album.title AS album_title,
  artist.name as artist,
  MAX(track.milliseconds / (1000 * 60) % 60 ) AS max_track_length_mins
-- Name the temp table #maxtracks
INTO #maxtracks
FROM album
-- Join album to artist using artist_id
INNER JOIN artist ON album.artist_id = artist.artist_id
-- Join track to album using album_id
INNER JOIN track ON album.album_id = track.album_id
GROUP BY artist.artist_id, album.title, artist.name,album.album_id
-- Run the final SELECT query to retrieve the results from the temporary table
SELECT album_title, artist, max_track_length_mins
FROM  #maxtracks
ORDER BY max_track_length_mins DESC, artist;
  