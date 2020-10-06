/*
Aliasing - team BMI
A basketball statistician would like to know the average Body Mass Index (BMI) per NBA team, in particular, any team with an average BMI of 25 or more. To include Team in the query, you will need to join the Players table to the PlayerStats table. The query will require aliasing to:
Easily identify joined tables and associated columns.
Identify sub-queries.
Avoid ambiguity in column names.
Identify new columns.
*/
SELECT Team, 
   ROUND(AVG(BMI),2) AS AvgTeamBMI -- Alias the new column
FROM PlayerStats AS ps -- Alias PlayerStats table
INNER JOIN
		(SELECT PlayerName, Country,
			Weight_kg/SQUARE(Height_cm/100) BMI
		 FROM Players) AS p -- Alias the sub-query
             -- Alias the joining columns
	ON ps.PlayerName = p.PlayerName 
GROUP BY Team
HAVING AVG(BMI) >= 25;

/*
Column does not exist
When using WHERE as a filter condition, it is important to think about the processing order in the query. In this exercise, you want a query that returns NBA players with average total rebounds of 12 or more per game. 
*/
-- Add the new column to the select statement
SELECT PlayerName, 
       Team, 
       Position, 
       AvgRebounds -- Add the new column
FROM
     -- Sub-query starts here                             
	(SELECT 
      PlayerName, 
      Team, 
      Position,
      -- Calculate average total rebounds
     (DRebound+ORebound)/CAST(GamesPlayed AS numeric) AS AvgRebounds
	 FROM PlayerStats) tr
WHERE AvgRebounds >= 12; -- Filter rows

/*
Remove duplicates with DISTINCT()
You want to know the closest city to earthquakes with a magnitude of 8 or higher. You can get this information from the Earthquakes table. However, a simple query returns duplicate rows because some cities have experienced more than one magnitude 8 or higher earthquake.
You can remove duplicates by using the DISTINCT() clause. Once you have your results, you would like to know how many times each city has experienced an earthquake of magnitude 8 or higher.
Note that IS NOT NULL is being used because many earthquakes do not occur near any populated area, thankfully.
*/
SELECT NearestPop, 
       Country, 
       COUNT(NearestPop) NumEarthquakes -- Number of cities
FROM Earthquakes
WHERE Magnitude >= 8
	AND Country IS NOT NULL
GROUP BY NearestPop, Country -- Group columns
ORDER BY NumEarthquakes DESC;

/*
UNION and UNION ALL
You want a query that returns all cities listed in the Earthquakes database. It should be an easy query on the Cities table. However, to be sure you get all cities in the database you will append the query to the Nations table to include capital cities as well. You will use UNION to remove any duplicate rows.
Out of curiosity, you want to know if there were any duplicate rows. If you do the same query but append with UNION ALL instead, and compare the number of rows returned in each query, UNION ALL will return more rows if there are duplicates.
*/
SELECT CityName AS NearCityName, -- City name column
	   CountryCode
FROM Cities

UNION -- Append queries

SELECT Capital AS NearCityName, -- Nation capital column
       Code2 AS CountryCode
FROM Nations;

/*
Uncorrelated sub-query
A sub-query is another query within a query. The sub-query returns its results to an outer query to be processed.
You want a query that returns the region and countries that have experienced earthquakes centered at a depth of 400km or deeper. Your query will use the Earthquakes table in the sub-query, and Nations table in the outer query.
*/
SELECT UNStatisticalRegion,
       CountryName 
FROM Nations
WHERE Code2 -- Country code for outer query 
         IN (SELECT Country -- Country code for sub-query
             FROM Earthquakes
             WHERE depth >= 400 ) -- Depth filter
ORDER BY UNStatisticalRegion;

/*
Correlated sub-query
Sub-queries are used to retrieve information from another table, or query, that is separate to the main query.
A friend is working on a project looking at earthquake hazards around the world. She requires a table that lists all countries, their continent and the average magnitude earthquake by country. This query will need to access data from the Nations and Earthquakes tables.
*/
SELECT UNContinentRegion,
       CountryName, 
        (SELECT AVG(magnitude) -- Add average magnitude
        FROM Earthquakes e 
         	  -- Add country code reference
        WHERE n.Code2 = e.Country) AS AverageMagnitude 
FROM Nations n
ORDER BY UNContinentRegion DESC, 
         AverageMagnitude DESC;

/*
Sub-query vs INNER JOIN
Often the results from a correlated sub-query can be replicated using an INNER JOIN. Depending on what your requirements are, using an INNER JOIN may be more efficient because it only makes one pass through the data whereas the correlated sub-query must execute for each row in the outer query.
You want to find out the 2017 population of the biggest city for every country in the world. You can get this information from the Earthquakes database with the Nations table as the outer query and Cities table in the sub-query.
You will first create this query as a correlated sub-query then rewrite it using an INNER JOIN.
*/
SELECT
	n.CountryName,
	 (SELECT MAX(c.Pop2017) -- Add 2017 population column
	 FROM Cities AS c 
                       -- Outer query country code column
	 WHERE c.CountryCode = n.Code2) AS BiggestCity
FROM Nations AS n; -- Outer query table

SELECT n.CountryName, 
       c.BiggestCity 
FROM Nations AS n
INNER JOIN -- Join the Nations table and sub-query
    (SELECT CountryCode, 
     MAX(Pop2017) AS BiggestCity 
     FROM Cities
     GROUP BY CountryCode) AS c
ON n.Code2 = c.CountryCode; -- Add the joining columns

/*
Interrogating with INTERSECT
INTERSECT and EXCEPT are very useful for data interrogation.
The Earthquakes and NBA Season 2017-2018 databases both contain information on countries and cities. You are interested to know which countries are represented by players in the 2017-2018 NBA season and you believe you can get the results you require by querying the relevant tables across these two databases.
Use the INTERSECT operator between queries, but be careful and think about the results. Although both tables contain a country name column to compare, these are separate databases and the data may be stored differently.
*/
SELECT CountryName 
FROM Nations -- Table from Earthquakes database

INTERSECT -- Operator for the intersect between tables

SELECT Country
FROM Players; -- Table from NBA Season 2017-2018 database

/*
IN and EXISTS
You want to know which, if any, country capitals are listed as the nearest city to recorded earthquakes. You can get this information using INTERSECT and comparing the Nations table with the Earthquakes table. However, INTERSECT requires that the number and order of columns in the SELECT statements must be the same between queries and you would like to include additional columns from the outer query in the results.
You attempt two queries, each with a different operator that gives you the results you require.
*/
-- First attempt
SELECT CountryName,
       Pop2017, -- 2017 country population
	   Capital, -- Capital city	   
       WorldBankRegion
FROM Nations
WHERE Capital IN -- Add the operator to compare queries
        (SELECT NearestPop 
	     FROM Earthquakes);

-- Second attempt
SELECT CountryName,   
	   Capital,
       Pop2016, -- 2016 country population
       WorldBankRegion
FROM Nations AS n
WHERE EXISTS -- Add the operator to compare queries
	  (SELECT 1
	   FROM Earthquakes AS e
	   WHERE n.Capital = e.NearestPop); -- Columns being compared

/*
NOT IN and NOT EXISTS
NOT IN and NOT EXISTS do the opposite of IN and EXISTS respectively. They are used to check if the data present in one table is absent in another.
You are interested to know if there are some countries in the Nations table that do not appear in the Cities table. There may be many reasons for this. For example, all the city populations from a country may be too small to be listed, or there may be no city data for a particular country at the time the data was compiled.
You will compare the queries using country codes.
*/
SELECT WorldBankRegion,
       CountryName
FROM Nations
WHERE Code2 NOT IN -- Add the operator to compare queries
	(SELECT CountryCode -- Country code column
	 FROM Cities);

SELECT WorldBankRegion,
       CountryName,
	   Code2,
       Capital, -- Country capital column
	   Pop2017
FROM Nations AS n
WHERE NOT EXISTS -- Add the operator to compare queries
	(SELECT 1
	 FROM Cities AS c
	 WHERE n.Code2 = c.CountryCode); -- Columns being compared

/*
NOT IN with IS NOT NULL
You want to know which country capitals have never been the closest city to recorded earthquakes. You decide to use NOT IN to compare Capital from the Nations table, in the outer query, with NearestPop, from the Earthquakes table, in a sub-query.
*/
SELECT WorldBankRegion,
       CountryName,
       Capital
FROM Nations
WHERE Capital NOT IN
	(SELECT NearestPop
     FROM Earthquakes
     WHERE NearestPop IS NOT NULL); -- filter condition

/*
INNER JOIN
An insurance company that specializes in sports franchises has asked you to assess the geological hazards of cities hosting NBA teams. You believe you can get this information by querying the Teams and Earthquakes tables across the Earthquakes and NBA Season 2017-2018 databases respectively. Your initial query will use EXISTS to compare tables. The second query will use a more appropriate operator.
*/
-- Initial query
SELECT TeamName,
       TeamCode,
	   City
FROM Teams AS t -- Add table
WHERE EXISTS -- Operator to compare queries
      (SELECT 1 
	  FROM Earthquakes AS e -- Add table
	  WHERE t.City = e.NearestPop);

-- Second query
SELECT t.TeamName,
       t.TeamCode,
	   t.City,
	   e.Date,
	   e.place, -- Place description
	   e.Country -- Country code
FROM Teams AS t
INNER JOIN Earthquakes AS e -- Operator to compare tables
	  ON t.City = e.NearestPop

/*
Exclusive LEFT OUTER JOIN
An exclusive LEFT OUTER JOIN can be used to check for the presence of data in one table that is absent in another table. To create an exclusive LEFT OUTER JOIN the right query requires an IS NULL filter condition on the joining column.
Your sales manager is concerned that orders from French customers are declining. He wants you to compile a list of French customers that have not placed any orders so he can contact them.
*/
-- First attempt
SELECT c.CustomerID,
       c.CompanyName,
	   c.ContactName,
	   c.ContactTitle,
	   c.Phone 
FROM Customers c
LEFT OUTER JOIN Orders o -- Joining operator
	ON c.CustomerID = o.CustomerID -- Joining columns
WHERE c.Country = 'France';

-- Second attempt
SELECT c.CustomerID,
       c.CompanyName,
	   c.ContactName,
	   c.ContactTitle,
	   c.Phone 
FROM Customers c
LEFT OUTER JOIN Orders o
	ON c.CustomerID = o.CustomerID
WHERE c.Country = 'France'
	AND o.OrderID IS NULL; -- Filter condition

/*
STATISTICS TIME in queries
A friend is writing a training course on how the command STATISTICS TIME can be used to tune query performance and asks for your help to complete a presentation. He requires two queries that return NBA team details where the host city had a 2017 population of more than two million.
NBA team details can be queried from the NBA Season 2017-2018 database and city populations can be queried by adding in tables from the Earthquakes database.
Each query uses a different filter on the Teams table.
Query 1
Filters the Teams table using IN and three sub-queries
Query 2
Filters the Teams table using EXISTS
*/
SET STATISTICS TIME ON -- Turn the time command on
-- Query 1
SELECT * 
FROM Teams
-- Sub-query 1
WHERE City IN -- Sub-query filter operator
      (SELECT CityName 
       FROM Cities) -- Table from Earthquakes database
-- Sub-query 2
   AND City IN -- Sub-query filter operator
	   (SELECT CityName 
	    FROM Cities
		WHERE CountryCode IN ('US','CA'))
-- Sub-query 3
    AND City IN -- Sub-query filter operator
        (SELECT CityName 
         FROM Cities
	     WHERE Pop2017 >2000000);
-- Query 2
SELECT * 
FROM Teams AS t
WHERE EXISTS -- Sub-query filter operator
	(SELECT 1 
     FROM Cities AS c
     WHERE t.City = c.CityName -- Columns being compared
        AND c.CountryCode IN ('US','CA')
          AND c.Pop2017 > 2000000);
SET STATISTICS TIME OFF -- Turn the time command off

/*
STATISTICS IO: Example 1
Your sales company has just taken on a new regional manager for Western Europe. He has asked you to provide him daily updates on orders shipped to some key Western Europe capital cities. As this data is time sensitive, you want a robust query that is tuned to return the results as quickly as possible.
You initially decide on a query that uses two sub-queries: one in the SELECT statement to get the count of orders and one using a filter condition with an IN operator.
You will turn on the STATISTICS IO command to review the page read statistics.
*/
SET STATISTICS IO ON -- Turn the IO command on
-- Example 1
SELECT CustomerID,
       CompanyName,
       (SELECT COUNT(*) 
	    FROM Orders AS o -- Add table
		WHERE c.CustomerID = o.CustomerID) CountOrders
FROM Customers AS c
WHERE CustomerID IN -- Add filter operator
       (SELECT CustomerID 
	    FROM Orders 
		WHERE ShipCity IN
            ('Berlin','Bern','Bruxelles','Helsinki',
			'Lisboa','Madrid','Paris','London'));

/*
STATISTICS IO: Example 2
In the previous exercise, you were asked you to provide a new regional manager daily updates on orders shipped to Western Europe capital cities. You initially created a query that contained two sub-queries. You decide to do a rewrite and use an INNER JOIN.
The STATISTICS IO command is turned on. You will need to turn it off after completing the query.
*/
-- Example 2
SELECT c.CustomerID,
       c.CompanyName,
       COUNT(o.CustomerID)
FROM Customers AS c
INNER JOIN Orders AS o -- Join operator
    ON c.CustomerID = o.CustomerID
WHERE o.ShipCity IN -- Shipping destination column
     ('Berlin','Bern','Bruxelles','Helsinki',
	 'Lisboa','Madrid','Paris','London')
GROUP BY c.CustomerID,
         c.CompanyName;
SET STATISTICS IO OFF -- Turn the IO command off

/*
Clustered index
Clustered indexes can be added to tables to speed up search operations in queries. You have two copies of the Cities table from the Earthquakes database: one copy has a clustered index on the CountryCode column. The other is not indexed.
You have a query on each table with a different filter condition:
Query 1
Returns all rows where the country is either Russia or China.
Query 2
Returns all rows where the country is either Jamaica or New Zealand.
*/
-- Query 1
SELECT *
FROM Cities
WHERE CountryCode = 'RU' -- Country code
		OR CountryCode = 'CN' -- Country code
-- Query 2
SELECT *
FROM Cities
WHERE CountryCode IN ('JM','NZ') -- Country codes
/*
Query 2 accesses a clustered index because logical reads indicates fewer data pages were accessed compared to Query 1
*/

/*
Sort operator in execution plans
Execution plans can tell us if and where a query used an internal sorting operation. Internal sorting is often required when using an operator in a query that checks for and removes duplicate rows.
You are given an execution plan of a query that returns all cities listed in the Earthquakes database. The query appends queries from the Nations and Cities tables. Use the following execution plan to determine if the appending operator used is UNION or UNION ALL
*/
SELECT CityName AS NearCityName,
	   CountryCode
FROM Cities

UNION -- Append queries

SELECT Capital AS NearCityName,
       Code2 AS CountryCode
FROM Nations;