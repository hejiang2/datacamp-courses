/*
The examples in this course are based on a data set about chocolate ratings (one of the most commonly consumed candies in the world).
This data set contains:
The ratings table: information about chocolate bars: the origin of the beans, percentage of cocoa and the rating of each bar.
The voters table: details about the people who participate in the voting process. 
	It contains personal information of a voter: first and last name, email address, gender, country, the first time they voted and the total number of votes.
*/
SELECT 
	company, 
	company_location, 
	bean_origin, 
	cocoa_percent, 
	rating
FROM ratings
-- Location should be Belgium and the rating should exceed 3.5
WHERE company_location = 'Belgium'
	AND rating > 3.5;
    
SELECT 
	first_name,
	last_name,
	birthdate,
	gender,
	email,
	country,
	total_votes
FROM voters
-- Birthdate > 1990-01-01, total_votes > 100 but < 200
WHERE birthdate > '1990-01-01'
  AND total_votes > 100
  AND total_votes < 200;
  
-- Add a new column with the correct data type, for storing the last date a person voted ("2018-01-17").
ALTER TABLE voters
ADD last_vote_date date;

-- Add a new column called last_vote_time, to keep track of the most recent time when a person voted ("16:55:00").
ALTER TABLE voters
ADD last_vote_time time;

-- Add a new column,last_login, storing the most recent time a person accessed the application ("2019-02-02 13:44:00").
ALTER TABLE voters
ADD last_login datetime2;

/*
This is what you need to remember about implicit conversion:
1. For comparing two values in SQL Server, they need to have the same data type.
2. If the data types are different, SQL Server implicitly converts one type to another, based on data type precedence.
3. The data type with the lower precedence is converted to the data type with the higher precedence.
*/
-- CASTing data
SELECT 
	-- Transform the year part from the birthdate to a string
	first_name + ' ' + last_name + ' was born in ' + CAST(YEAR(birthdate) AS nvarchar) + '.' 
FROM voters;  

SELECT 
	-- Transform to int the division of total_votes to 5.5
	CAST(total_votes/5.5 AS INT) AS DividedVotes
FROM voters;

SELECT 
	first_name,
	last_name,
	total_votes
FROM voters
-- Transform the total_votes to char of length 10
WHERE CAST(total_votes AS VARCHAR(10)) LIKE '5%';

-- CONVERTing data
-- They are very similar in functionality, with the exception that with CONVERT() you can use a style parameter for changing the aspect of a date.
-- CONVERT() is SQL Server specific, so its performance is slightly better than CAST().
SELECT 
	email,
    -- Convert birthdate to varchar show it like: "Mon dd,yyyy" 
    CONVERT(varchar, birthdate, 107) AS birthdate
FROM voters;

SELECT 
	company,
    bean_origin,
    -- Convert the rating column to an integer
    CONVERT(INT, rating) AS rating
FROM ratings;

SELECT 
	company,
    bean_origin,
    rating
FROM ratings
-- Convert the rating to an integer before comparison
WHERE CONVERT(INT, rating) = 3;

SELECT
	first_name,
    last_name,
	-- Convert birthdate to varchar(10) to show it as yy/mm/dd
	CONVERT(varchar(10), birthdate, 11) AS birthdate,
    gender,
    country,
    -- Convert the total_votes number to nvarchar
    'Voted ' + CAST(total_votes AS nvarchar) + ' times.' AS comments
FROM voters
WHERE country = 'Belgium'
    -- Select only the female voters
	AND gender = 'F'
    -- Select only people who voted more than 20 times
    AND total_votes > 20;
    
-- Get the know the system date and time functions
-- Use the most common date function for retrieving the current date.
SELECT 
	SYSDATETIME() AS CurrentDate;
-- Select the current date in UTC time (Universal Time Coordinate) using two different functions.
SELECT 
	SYSUTCDATETIME() AS UTC_HighPrecision,
	GETUTCDATE() AS UTC_LowPrecision;    
-- Select the local system's date, including the timezone information.
SELECT 
	SYSDATETIMEOFFSET() AS Timezone;
-- Use two functions to query the system's local date, without timezone information. Show the dates in different formats.
SELECT 
	CONVERT(VARCHAR(24), GETDATE(), 107) AS HighPrecision,
	CONVERT(VARCHAR(24), GETDATE(), 102) AS LowPrecision;
-- Use two functions to retrieve the current time, in Universal Time Coordinate.
SELECT 
	CAST(SYSUTCDATETIME() AS time) AS HighPrecision,
	CAST(GETUTCDATE() AS time) AS LowPrecision;    

-- Extracting parts from a date    
SELECT 
	first_name,
	last_name,
   	-- Extract the year of the first vote
	YEAR(first_vote_date)  AS first_vote_year,
    -- Extract the month of the first vote
	MONTH(first_vote_date) AS first_vote_month,
    -- Extract the day of the first vote
	DAY(first_vote_date)   AS first_vote_day
FROM voters
-- The year of the first vote should be greater than 2015
WHERE YEAR(first_vote_date) > 2015
-- The day should not be the first day of the month
  AND DAY(first_vote_date) <> 1;
  
-- Create a new date column representing the first day in the month of the first vote  
SELECT 
	first_name,
	last_name,
    -- Select the year of the first vote
   	YEAR(first_vote_date) AS first_vote_year, 
    -- Select the month of the first vote
	MONTH(first_vote_date) AS first_vote_month,
    -- Create a date as the start of the month of the first vote
	DATEFROMPARTS(YEAR(first_vote_date), MONTH(first_vote_date), 1) AS first_vote_starting_month
FROM voters;  

-- Calculating the difference between dates
SELECT
	first_name,
	birthdate,
	first_vote_date,
    -- Select the diff between the 18th birthday and first vote
	DATEDIFF(YEAR, DATEADD(YEAR, 18, birthdate), first_vote_date) AS adult_years_until_vote
FROM voters;

-- Changing the default language
DECLARE @date1 NVARCHAR(20) = '12/18/55';

-- Set the correct language
SET LANGUAGE English;
SELECT
	@date1 AS initial_date,
    -- Check that the date is valid
	ISDATE(@date1) AS is_valid,
    -- Select the week day name
	DATENAME(Weekday, @date1) AS week_day,
	-- Extract the year from the date
	YEAR(@date1) AS year_name;

-- Correctly applying different date functions
SELECT
	first_name,
    last_name,
    birthdate,
	first_vote_date,
	-- Find out on which day of the week each participant voted 
	DATENAME(weekday, first_vote_date) AS first_vote_weekday,
	-- Find out the year of the first vote
	YEAR(first_vote_date) AS first_vote_year,
	-- Discover the participants' age when they joined the contest
	DATEDIFF(YEAR, birthdate, first_vote_date) AS age_at_first_vote,	
	-- Calculate the current age of each voter
	DATEDIFF(YEAR, birthdate, GETDATE()) AS current_age
FROM voters;

-- Calculating the length of a string
SELECT TOP 10 
	company, 
	broad_bean_origin,
	-- Calculate the length of the broad_bean_origin column
	LEN(broad_bean_origin) AS length
FROM ratings
--Order the results based on the new column, descending
ORDER BY length DESC;

-- Looking for a string within a string
SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for the "dan" expression in the first_name
WHERE CHARINDEX('dan', first_name) > 0 
    -- Look for last_names that do not contain the letter "z"
	AND CHARINDEX('z', last_name) = 0;
    
-- Looking for a pattern within a string
SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for first names that contain "rr" in the middle
WHERE PATINDEX('%rr%', first_name) > 0;

SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for first names that start with C and the 3rd letter is r
WHERE PATINDEX('C_r%', first_name)>0;

SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for first names that have an "a" followed by 0 or more letters and then have a "w"
WHERE PATINDEX('%a%w%', first_name)>0;

SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for first names that contain one of the letters: "x", "w", "q"
WHERE PATINDEX('%[xwq]%', first_name)>0;

-- Changing to lowercase and uppercase
SELECT 
	company,
	bean_type,
	broad_bean_origin,
    -- 'company' and 'broad_bean_origin' should be in uppercase
	'The company ' +  UPPER(company) + ' uses beans of type "' + bean_type + '", originating from ' + UPPER(broad_bean_origin) + '.'
FROM ratings
WHERE 
    -- The 'broad_bean_origin' should not be unknown
	LOWER(broad_bean_origin) NOT LIKE '%unknown%'
     -- The 'bean_type' should not be unknown
    AND LOWER(bean_type) NOT LIKE '%unknown%';
    
-- Using the beginning or end of a string
SELECT 
	first_name,
	last_name,
	country,
    -- Select only the first 3 characters from the first name
	LEFT(first_name, 3) AS part1,
    -- Select only the last 3 characters from the last name
    RIGHT(last_name, 3) AS part2,
    -- Select only the last 2 digits from the birth date
    RIGHT(birthdate, 2) AS part3,
    -- Create the alias for each voter
    LEFT(first_name, 3) + RIGHT(last_name, 3) + '_' + RIGHT(birthdate, 2)
FROM voters;

-- Concatenating data
DECLARE @string1 NVARCHAR(100) = 'Chocolate with beans from';
DECLARE @string2 NVARCHAR(100) = 'has a cocoa percentage of';

SELECT 
	bean_type,
	bean_origin,
	cocoa_percent,
	-- Create a message by concatenating values with "+"
	@string1 + ' ' + bean_origin + ' ' + @string2 + ' ' + CAST(cocoa_percent AS nvarchar) AS message1,
	-- Create a message by concatenating values with "CONCAT()"
	CONCAT(@string1, ' ', bean_origin, ' ', @string2, ' ', cocoa_percent) AS message2,
	-- Create a message by concatenating values with "CONCAT_WS()"
	CONCAT_WS(' ', @string1, bean_origin, @string2, cocoa_percent) AS message3
FROM ratings
WHERE 
	company = 'Ambrosia' 
	AND bean_type <> 'Unknown';
    
-- Aggregating strings
SELECT 
	company,
    -- Create a list with all bean origins ordered alphabetically
	STRING_AGG(bean_origin, ',') WITHIN GROUP (ORDER BY bean_origin ASC) AS bean_origins
FROM ratings
WHERE company IN ('Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters')
-- Specify the columns used for grouping your data
GROUP BY company;

-- Splitting a string into pieces
DECLARE @phrase NVARCHAR(MAX) = 'In the morning I brush my teeth. In the afternoon I take a nap. In the evening I watch TV.'

SELECT value
FROM STRING_SPLIT(@phrase, ' ');    

-- Applying various string functions on data
SELECT
    -- Concatenate the first and last name
	CONCAT('***' , first_name, ' ', UPPER(last_name), '***') AS name,
    -- Mask the last two digits of the year
    REPLACE(birthdate, SUBSTRING(CAST(birthdate AS varchar), 3, 2), 'XX') AS birthdate,
	email,
	country
FROM voters
   -- Select only voters with a first name less than 5 characters
WHERE LEN(first_name) < 5
   -- Look for this pattern in the email address: "j%[0-9]@yahoo.com"
	AND PATINDEX('j_a%@yahoo.com', email) > 0;    
    
-- Learning how to count and add
SELECT 
	gender, 
	-- Count the number of voters for each group
	COUNT(*) AS voters,
	-- Calculate the total number of votes per group
	SUM(total_votes) AS total_votes
FROM voters
GROUP BY gender;

-- MINimizing and MAXimizing some results
SELECT 
	company,
	-- Calculate the average cocoa percent
	AVG(cocoa_percent) AS avg_cocoa,
	-- Calculate the minimum rating received by each company
	MIN(rating) AS min_rating,
	-- Calculate the maximum rating received by each company
	MAX(rating) AS max_rating
FROM ratings
GROUP BY company
-- Order the values by the maximum rating
ORDER BY MAX(rating) DESC;

-- Accessing values from the next row
/*
With the LEAD() function, you can access data from a subsequent row in the same query, without using the GROUP BY statement.
This way, you can easily compare values from an ordered list.
*/
SELECT 
	first_name,
	last_name,
	total_votes AS votes,
    -- Select the number of votes of the next voter
	LEAD(total_votes) OVER (ORDER BY total_votes) AS votes_next_voter,
    -- Calculate the difference between the number of votes
	LEAD(total_votes) OVER (ORDER BY total_votes) - total_votes AS votes_diff
FROM voters
WHERE country = 'France'
ORDER BY total_votes;    

-- Accessing values from the previous row
SELECT 
	broad_bean_origin AS bean_origin,
	rating,
	cocoa_percent,
    -- Retrieve the cocoa % of the bar with the previous rating
	LAG(cocoa_percent) 
		OVER(PARTITION BY broad_bean_origin ORDER BY rating) AS percent_lower_rating
FROM ratings
WHERE company = 'Fruition'
ORDER BY broad_bean_origin, rating ASC;

-- Getting the first and last value
SELECT 
	first_name + ' ' + last_name AS name,
	country,
	birthdate,
	-- Retrieve the birthdate of the oldest voter per country
	FIRST_VALUE(birthdate) 
	OVER (PARTITION BY country ORDER BY birthdate) AS oldest_voter,
	-- Retrieve the birthdate of the youngest voter per country
	LAST_VALUE(birthdate) 
		OVER (PARTITION BY country ORDER BY birthdate ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
				) AS youngest_voter
FROM voters
WHERE country IN ('Spain', 'USA');
