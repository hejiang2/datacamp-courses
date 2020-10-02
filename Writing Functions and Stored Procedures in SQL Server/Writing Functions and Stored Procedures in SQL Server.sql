/*
Transactions per day
It's time for you to do some temporal EDA on the BikeShare dataset.
Write a query to determine how many transactions exist per day.
Sometimes datasets have multiple sources and this query can help you understand if you are missing data.
*/
SELECT
  -- Select the date portion of StartDate
  CONVERT(DATE, StartDate) as StartDate,
  -- Measure how many records exist for each StartDate
  COUNT(ID) as CountOfRows 
FROM CapitalBikeShare 
-- Group by the date portion of StartDate
GROUP BY CONVERT(DATE, StartDate)
-- Sort the results by the date portion of StartDate
ORDER BY CONVERT(DATE, StartDate);  

/*
Seconds or no seconds?
How do you know the dataset includes seconds in the transactions?
Here, you'll use DATEPART() to see how many transactions have seconds greater than zero and how many have them equal to zero.
Then you can evaluate if this is an appropriate amount. The CASE statement will segregate the dataset into two categories.
*/
SELECT
	-- Count the number of IDs
	COUNT(ID) AS Count,
    -- Use DATEPART() to evaluate the SECOND part of StartDate
    "StartDate" = CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
					   WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END
FROM CapitalBikeShare
GROUP BY
    -- Use DATEPART() to Group By the CASE statement
	CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
		 WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END
         
/*
Which day of week is busiest?
Now that we verified there are seconds consistently in our dataset we can calculate the Total Trip Time for each day of the week.
*/         
SELECT
    -- Select the day of week value for StartDate
	DATENAME(WEEKDAY, StartDate) as DayOfWeek,
    -- Calculate TotalTripHours
	SUM(DATEDIFF(SECOND, StartDate, EndDate))/ 3600 as TotalTripHours 
FROM CapitalBikeShare 
-- Group by the day of week
GROUP BY DATENAME(WEEKDAY, StartDate)
-- Order TotalTripHours in descending order
ORDER BY TotalTripHours DESC

/*
Find the outliers
The previous exercise showed us that Saturday was the busiest day of the month for BikeShare rides.
Do you wonder if there were any individual Saturday outliers that contributed to this?
*/
SELECT
	-- Calculate TotalRideHours using SUM() and DATEDIFF()
  	SUM(DATEDIFF(SECOND, StartDate, EndDate))/ 3600 AS TotalRideHours,
    -- Select the DATE portion of StartDate
  	CONVERT(DATE, StartDate) AS DateOnly,
    -- Select the WEEKDAY
  	DATENAME(WEEKDAY, CONVERT(DATE, StartDate)) AS DayOfWeek 
FROM CapitalBikeShare
-- Only include Saturday
WHERE DATENAME(WEEKDAY, StartDate) = 'Saturday' 
GROUP BY CONVERT(DATE, StartDate);

/*
DECLARE & CAST
Let's use DECLARE() and CAST() to combine a date variable and a time variable into a datetime variable.
*/
-- Create @ShiftStartTime
DECLARE @ShiftStartTime AS time = '08:00 AM'

-- Create @StartDate
DECLARE @StartDate AS date

-- Set StartDate to the first StartDate from CapitalBikeShare
SET 
	@StartDate = (
    	SELECT TOP 1 StartDate 
    	FROM CapitalBikeShare 
    	ORDER BY StartDate ASC
		)

-- Create ShiftStartDateTime
DECLARE @ShiftStartDateTime AS datetime

-- Cast StartDate and ShiftStartTime to datetime data types
SET @ShiftStartDateTime = CAST(@StartDate AS datetime) + CAST(@ShiftStartTime AS datetime) 

SELECT @ShiftStartDateTime

/*
DECLARE a TABLE
Let's create a TABLE variable to store Shift data and then populate it with static values.
*/
-- Declare @Shifts as a TABLE
DECLARE @Shifts Table(
    -- Create StartDateTime column
	StartDateTime datetime,
    -- Create EndDateTime column
	EndDateTime datetime)
-- Populate @Shifts
INSERT INTO @Shifts (StartDateTime, EndDateTime)
	SELECT '3/1/2018 8:00 AM', '3/1/2018 4:00 PM'
SELECT * 
FROM @Shifts

/*
INSERT INTO @TABLE
Instead of storing static values in a table variable, let's store the result of a query.
*/
-- Declare @RideDates
DECLARE @RideDates TABLE(
    -- Define RideStart column
	RideStart date, 
    -- Define RideEnd column
    RideEnd date)
-- Populate @RideDates
INSERT INTO @RideDates(RideStart, RideEnd)
-- Select the unique date values of StartDate and EndDate
SELECT DISTINCT
    -- Cast StartDate as date
	CAST(StartDate as date),
    -- Cast EndDate as date
	CAST(EndDate as date) 
FROM CapitalBikeShare 
SELECT * 
FROM @RideDates

/*
First day of month
Here you will use the GETDATE(), DATEDIFF(), and DATEADD() functions to find the first day of the current month.
*/
-- Find the first day of the current month
-- Find the current date value.
-- Calculate the difference in months between today and 0 (1/1/1900 in SQL).
-- Add 0 months to that difference to get the first day of the month.
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)

/*
What was yesterday?
Create a function that returns yesterday's date.
*/
-- Create GetYesterday()
CREATE FUNCTION GetYesterday()
-- Specify return data type
RETURNS date
AS
BEGIN
-- Calculate yesterday's date value
RETURN (SELECT DATEADD(day, -1, GETDATE()))
END 

/*
One in one out
Create a function named SumRideHrsSingleDay() which returns the total ride time in hours for the @DateParm parameter passed.
*/
-- Create SumRideHrsSingleDay
CREATE FUNCTION SumRideHrsSingleDay (@DateParm date)
-- Specify return data type
RETURNS numeric
AS
-- Begin
BEGIN
RETURN
-- Add the difference between StartDate and EndDate
(SELECT SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
 -- Only include transactions where StartDate = @DateParm
WHERE CAST(StartDate AS date) = @DateParm)
-- End
END

/*
Multiple inputs one output
Often times you will need to pass more than one parameter to a function.
Create a function that accepts @StartDateParm and @EndDateParm and returns the total ride hours for all transactions that have a StartDate within the parameter values.
*/
-- Create the function
CREATE FUNCTION SumRideHrsDateRange (@StartDateParm datetime, @EndDateParm datetime)
-- Specify return data type
RETURNS numeric
AS
BEGIN
RETURN
-- Sum the difference between StartDate and EndDate
(SELECT SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
-- Include only the relevant transactions
WHERE StartDate > @StartDateParm and StartDate < @EndDateParm)
END

/*
Inline TVF
Create an inline table value function that returns the number of rides and total ride duration for each StartStation where the StartDate of the ride is equal to the input parameter.
*/
-- Create the function
CREATE FUNCTION SumStationStats(@StartDate AS datetime)
-- Specify return data type
RETURNS TABLE
AS
RETURN
SELECT
	StartStation,
    -- Use COUNT() to select RideCount
	COUNT(ID) AS RideCount,
    -- Use SUM() to calculate TotalDuration
    SUM(DURATION) AS TotalDuration
FROM CapitalBikeShare
WHERE CAST(StartDate as Date) = @StartDate
-- Group by StartStation
GROUP BY StartStation;

/*
Multi statement TVF
Create a multi statement table value function that returns the trip count and average ride duration for each day for the month & year parameter values passed.
*/
-- Create the function
CREATE FUNCTION CountTripAvgDuration (@Month CHAR(2), @Year CHAR(4))
-- Specify return variable
RETURNS @DailyTripStats TABLE(
	TripDate	date,
	TripCount	int,
	AvgDuration	numeric)
AS
BEGIN
-- Insert query results into @DailyTripStats
INSERT INTO @DailyTripStats
SELECT
    -- Cast StartDate as a date
	CAST(StartDate AS date),
    COUNT(ID),
    AVG(Duration)
FROM CapitalBikeShare
WHERE
	DATEPART(month, StartDate) = @Month AND
    DATEPART(year, StartDate) = @Year
-- Group by StartDate as a date
GROUP BY CAST(StartDate AS date)
-- Return
RETURN
END

/*
Execute scalar with select
Previously, you created a scalar function named SumRideHrsDateRange(). 
Execute that function for the '3/1/2018' through '3/10/2018' date range by passing local date variables.
*/
-- Create @BeginDate
DECLARE @BeginDate AS date = '3/1/2018'
-- Create @EndDate
DECLARE @EndDate AS date = '3/10/2018' 
SELECT
  -- Select @BeginDate
  @BeginDate AS BeginDate,
  -- Select @EndDate
  @EndDate AS EndDate,
  -- Execute SumRideHrsDateRange()
  dbo.SumRideHrsDateRange(@BeginDate, @EndDate) AS TotalRideHrs
  
/*
EXEC scalar
You created the SumRideHrsSingleDay function earlier in this chapter. 
Execute that function using the EXEC keyword and store the result in a local variable.
*/
-- Create @RideHrs
DECLARE @RideHrs AS numeric
-- Execute SumRideHrsSingleDay function and store the result in @RideHrs
EXEC @RideHrs = dbo.SumRideHrsSingleDay @DateParm = '3/5/2018' 
SELECT 
  'Total Ride Hours for 3/5/2018:', 
  @RideHrs
  
/*
Execute TVF into variable
Remember the table value function you created earlier in this chapter named SumStationStats?.
It accepts a datetime parameter and returns the ride count and total ride duration for each starting station where the start date matches the input parameter. 
Execute SumStationStats now and store the results in a table variable.
*/
-- Create @StationStats
DECLARE @StationStats TABLE(
	StartStation nvarchar(100), 
	RideCount int, 
	TotalDuration numeric)
-- Populate @StationStats with the results of the function
INSERT INTO @StationStats
SELECT TOP 10 *
-- Execute SumStationStats with 3/15/2018
FROM dbo.SumStationStats('3/15/2018') 
ORDER BY RideCount DESC
-- Select all the records from @StationStats
SELECT * 
FROM @StationStats

/*
CREATE OR ALTER
Change the SumStationStats function to enable SCHEMABINDING.
Also change the parameter name to @EndDate and compare to EndDate of CapitalBikeShare table.
*/
-- Update SumStationStats
CREATE OR ALTER FUNCTION dbo.SumStationStats(@EndDate AS date)
-- Enable SCHEMABINDING
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT
	StartStation,
    COUNT(ID) AS RideCount,
    SUM(DURATION) AS TotalDuration
FROM dbo.CapitalBikeShare
-- Cast EndDate as date and compare to @EndDate
WHERE CAST(EndDate AS Date) = @EndDate
GROUP BY StartStation;

/*
CREATE PROCEDURE with OUTPUT
Create a Stored Procedure named cuspSumRideHrsSingleDay in the dbo schema that accepts a date and returns the total ride hours for the date passed.
*/
-- Create the stored procedure
CREATE PROCEDURE dbo.cuspSumRideHrsSingleDay
    -- Declare the input parameter
	@DateParm date,
    -- Declare the output parameter
	@RideHrsOut numeric OUTPUT
AS
-- Don't send the row count 
SET NOCOUNT ON
BEGIN
-- Assign the query result to @RideHrsOut
SELECT
	@RideHrsOut = SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
-- Cast StartDate as date and compare with @DateParm
WHERE CAST(StartDate AS date) = @DateParm
RETURN
END

/*
Use SP to INSERT
Create a stored procedure named cusp_RideSummaryCreate in the dbo schema that will insert a record into the RideSummary table.
*/  
-- Create the stored procedure
CREATE PROCEDURE dbo.cusp_RideSummaryCreate 
    (@DateParm date, @RideHrsParm numeric)
AS
BEGIN
SET NOCOUNT ON
-- Insert into the Date and RideHours columns
INSERT INTO dbo.RideSummary(Date, RideHours)
-- Use values of @DateParm and @RideHrsParm
VALUES(@DateParm, @RideHrsParm) 

-- Select the record that was just inserted
SELECT
    -- Select Date column
	Date,
    -- Select RideHours column
    RideHours
FROM dbo.RideSummary
-- Check whether Date equals @DateParm
WHERE Date = @DateParm
END;

/*
Use SP to UPDATE
Create a stored procedure named cuspRideSummaryUpdate in the dbo schema that will update an existing record in the RideSummary table.
*/
-- Create the stored procedure
CREATE PROCEDURE dbo.cuspRideSummaryUpdate
	-- Specify @Date input parameter
	(@Date date,
     -- Specify @RideHrs input parameter
     @RideHrs numeric(18,0))
AS
BEGIN
SET NOCOUNT ON
-- Update RideSummary
UPDATE RideSummary
-- Set
SET
	Date = @Date,
    RideHours = @RideHrs
-- Include records where Date equals @Date
WHERE Date = @Date
END;

/*
Use SP to DELETE
Create a stored procedure named cuspRideSummaryDelete in the dbo schema that will delete an existing record in the RideSummary table and RETURN the number of rows affected via output parameter.
*/
-- Create the stored procedure
CREATE PROCEDURE dbo.cuspRideSummaryDelete
	-- Specify @DateParm input parameter
	(@DateParm date,
     -- Specify @RowCountOut output parameter
     @RowCountOut int OUTPUT)
AS
BEGIN
-- Delete record(s) where Date equals @DateParm
DELETE FROM dbo.RideSummary
WHERE Date = @DateParm
-- Set @RowCountOut to @@ROWCOUNT
SET @RowCountOut = @@ROWCOUNT
END;

/*
EXECUTE with OUTPUT parameter
Execute the dbo.cuspSumRideHrsSingleDay stored procedure and capture the output parameter.
*/
-- Create @RideHrs
DECLARE @RideHrs AS numeric(18,0)
-- Execute the stored procedure
EXEC dbo.cuspSumRideHrsSingleDay
    -- Pass the input parameter
	@DateParm = '3/1/2018',
    -- Store the output in @RideHrs
	@RideHrsOut = @RideHrs OUTPUT
-- Select @RideHrs
SELECT @RideHrs AS RideHours

/*
EXECUTE with return value
Execute dbo.cuspRideSummaryUpdate to change the RideHours to 300 for '3/1/2018'. 
Store the return code from the stored procedure.
*/
-- Create @ReturnStatus
DECLARE @ReturnStatus AS int
-- Execute the SP
EXEC @ReturnStatus = dbo.cuspRideSummaryUpdate
    -- Specify @DateParm
	@DateParm = '3/1/2018',
    -- Specify @RideHrs
	@RideHrs = 300

-- Select the columns of interest
SELECT
	@ReturnStatus AS ReturnStatus,
    Date,
    RideHours
FROM dbo.RideSummary 
WHERE Date = '3/1/2018';

/*
EXECUTE with OUTPUT & return value
Store and display both the output parameter and return code when executing dbo.cuspRideSummaryDelete SP.
*/
-- Create @ReturnStatus
DECLARE @ReturnStatus AS int
-- Create @RowCount
DECLARE @RowCount AS int

-- Execute the SP, storing the result in @ReturnStatus
EXEC @ReturnStatus = dbo.cuspRideSummaryDelete 
    -- Specify @DateParm
	@DateParm = '3/1/2018',
    -- Specify RowCountOut
	@RowCountOut = @RowCount OUTPUT

-- Select the columns of interest
SELECT
	@ReturnStatus AS ReturnStatus,
    @RowCount as 'RowCount';
    
/*
Your very own TRY..CATCH
Alter dbo.cuspRideSummaryDelete to include an intentional error so we can see how the TRY CATCH block works.
*/
-- Alter the stored procedure
CREATE OR ALTER PROCEDURE dbo.cuspRideSummaryDelete
	-- (Incorrectly) specify @DateParm
	@DateParm nvarchar(30),
    -- Specify @Error
	@Error nvarchar(max) = NULL OUTPUT
AS
SET NOCOUNT ON
BEGIN
  -- Start of the TRY block
  BEGIN TRY
  	  -- Delete
      DELETE FROM RideSummary
      WHERE Date = @DateParm
  -- End of the TRY block
  END TRY
  -- Start of the CATCH block
  BEGIN CATCH
		SET @Error = 
		'Error_Number: '+ CAST(ERROR_NUMBER() AS VARCHAR) +
		'Error_Severity: '+ CAST(ERROR_SEVERITY() AS VARCHAR) +
		'Error_State: ' + CAST(ERROR_STATE() AS VARCHAR) + 
		'Error_Message: ' + ERROR_MESSAGE() + 
		'Error_Line: ' + CAST(ERROR_LINE() AS VARCHAR)
  -- End of the CATCH block
  END CATCH
END;

/*
CATCH an error
Execute dbo.cuspRideSummaryDelete and pass an invalid @DateParm value of '1/32/2018' to see how the error is handled.
The invalid date will be accepted by the nvarchar data type of @DateParm, but the error will occur when SQL attempts to convert it to a valid date when executing the stored procedure.
*/
-- Create @ReturnCode
DECLARE @ReturnCode integer
-- Create @ErrorOut
DECLARE @ErrorOut nvarchar(max)
-- Execute the SP, storing the result in @ReturnCode
EXEC @ReturnCode = dbo.cuspRideSummaryDelete
    -- Specify @DateParm
	@DateParm = '1/32/2018',
    -- Assign @ErrorOut to @Error
	@Error = @ErrorOut OUTPUT
-- Select @ReturnCode and @ErrorOut
SELECT
	@ReturnCode AS ReturnCode,
    @ErrorOut AS ErrorMessage
;
    
-- NYC Taxi Ride Case Study
/*
Use EDA to find impossible scenarios
Calculate how many YellowTripData records have each type of error discovered during EDA.
*/
SELECT
	-- PickupDate is after today
	COUNT (CASE WHEN PickupDate > GETDATE() THEN 1 END) AS 'FuturePickup',
    -- DropOffDate is after today
	COUNT (CASE WHEN DropOffDate > GETDATE() THEN 1 END) AS 'FutureDropOff',
    -- PickupDate is after DropOffDate
	COUNT (CASE WHEN PickupDate > DropOffDate THEN 1 END) AS 'PickupBeforeDropoff',
    -- TripDistance is 0
	COUNT (CASE WHEN TripDistance = 0 THEN 1 END) AS 'ZeroTripDistance'  
FROM YellowTripData;

/*
Mean imputation
Create a stored procedure that will apply mean imputation to the YellowTripData records with an incorrect TripDistance of zero. 
The average trip distance variable should have a precision of 18 and 4 decimal places.
*/
-- Create the stored procedure
CREATE PROCEDURE dbo.cuspImputeTripDistanceMean
AS
BEGIN
-- Specify @AvgTripDistance variable
DECLARE @AvgTripDistance AS numeric (18,4)

-- Calculate the average trip distance
SELECT @AvgTripDistance = AVG(TripDistance) 
FROM YellowTripData
-- Only include trip distances greater than 0
WHERE TripDistance > 0 

-- Update the records where trip distance is 0
UPDATE YellowTripData
SET TripDistance = @AvgTripDistance
WHERE TripDistance = 0
END;

/*
Hot Deck imputation
Create a function named dbo.GetTripDistanceHotDeck that returns a TripDistance value via Hot Deck methodology.
TripDistance should have a precision of 18 and 4 decimal places.
*/
-- Create the function
CREATE FUNCTION dbo.GetTripDistanceHotDeck()
-- Specify return data type
RETURNS numeric (18,4)
AS 
BEGIN
RETURN
	-- Select the first TripDistance value
	(SELECT TOP 1 TripDistance
	FROM YellowTripData
    -- Sample 1000 records
	TABLESAMPLE(1000 rows)
    -- Only include records where TripDistance is > 0
	WHERE TripDistance > 0)
END;

/*
CREATE FUNCTIONs
Create three functions to help solve the business case:
1. Convert distance from miles to kilometers.
2. Convert currency based on exchange rate parameter.
(These two functions should return a numeric value with precision of 18 and 2 decimal places.)
3. Identify the driver shift based on the hour parameter value passed.
*/
-- Create the function
CREATE FUNCTION dbo.ConvertMileToKm (@Miles numeric(18,2))
-- Specify return data type
RETURNS numeric(18,2)
AS
BEGIN
RETURN
	-- Convert Miles to Kilometers
	(SELECT @Miles * 1.609)
END;

-- Create the function
CREATE FUNCTION dbo.ConvertDollar
	-- Specify @DollarAmt parameter
	(@DollarAmt numeric(18,2),
     -- Specify ExchangeRate parameter
     @ExchangeRate numeric(18,2))
-- Specify return data type
RETURNS numeric(18,2)
AS
BEGIN
RETURN
	-- Multiply @ExchangeRate and @DollarAmt
	(SELECT @ExchangeRate * @DollarAmt)
END;

-- Create the function
CREATE FUNCTION dbo.GetShiftNumber (@Hour integer)
-- Specify return data type
RETURNS int
AS
BEGIN
RETURN
	-- 12am (0) to 9am (9) shift
	(CASE WHEN @Hour >= 0 AND @Hour < 9 THEN 1
     	  -- 9am (9) to 5pm (17) shift
		 WHEN @Hour >= 9 AND @Hour < 17 THEN 2
          -- 5pm (17) to 12am (24) shift
	     WHEN @Hour >= 17 AND @Hour < 24 THEN 3 END)
END;

/*
Test FUNCTIONs
Now it's time to test the three functions you wrote in the previous exercise.
*/
SELECT
	-- Select the first 100 records of PickupDate
	TOP 100 PickupDate,
    -- Determine the shift value of PickupDate
	dbo.GetShiftNumber(DATEPART(HOUR, PickupDate)) AS 'Shift',
    -- Select FareAmount
	FareAmount,
    -- Convert FareAmount to Euro
	dbo.ConvertDollar(FareAmount, 0.87) AS 'FareinEuro',
    -- Select TripDistance
	TripDistance,
    -- Convert TripDistance to kilometers
	dbo.ConvertMiletoKm(TripDistance) AS 'TripDistanceinKM'
FROM YellowTripData
-- Only include records for the 2nd shift
WHERE dbo.GetShiftNumber(DATEPART(HOUR, PickupDate)) = 2;

/*
Logical weekdays with Hot Deck
Calculate Total Fare Amount per Total Distance for each day of week.
If the TripDistance is zero use the Hot Deck imputation function you created earlier in the chapter.
*/
SELECT
    -- Select the pickup day of week
	DATENAME(weekday, PickupDate) as DayofWeek,
    -- Calculate TotalAmount per TripDistance
	CAST(AVG(TotalAmount/
            -- Select TripDistance if it's more than 0
			CASE WHEN TripDistance > 0 THEN TripDistance
                 -- Use GetTripDistanceHotDeck()
     			 ELSE dbo.GetTripDistanceHotDeck() END) as decimal(10,2)) as 'AvgFare'
FROM YellowTripData
GROUP BY DATENAME(weekday, PickupDate)
-- Order by the PickupDate day of week
ORDER BY
     CASE WHEN DATENAME(weekday, PickupDate) = 'Monday' THEN 1
          WHEN DATENAME(weekday, PickupDate) = 'Tuesday' THEN 2
          WHEN DATENAME(weekday, PickupDate) = 'Wednesday' THEN 3
          WHEN DATENAME(weekday, PickupDate) = 'Thursday' THEN 4
          WHEN DATENAME(weekday, PickupDate) = 'Friday' THEN 5
          WHEN DATENAME(weekday, PickupDate) = 'Saturday' THEN 6
          WHEN DATENAME(weekday, PickupDate) = 'Sunday' THEN 7
END ASC;

/*
Format for Germany
Write a query to display the TotalDistance, TotalRideTime and TotalFare for each day and NYC Borough. 
Display the date, distance, ride time, and fare totals for German culture.
*/
SELECT
    -- Cast PickupDate as a date and display as a German date
	FORMAT(CAST(PickupDate AS Date), 'd', 'de-de') AS 'PickupDate',
	Zone.Borough,
    -- Display TotalDistance in the German format
	FORMAT(SUM(TripDistance), 'n', 'de-de') AS 'TotalDistance',
    -- Display TotalRideTime in the German format
	FORMAT(SUM(DATEDIFF(minute, PickupDate, DropoffDate)), 'n', 'de-de') AS 'TotalRideTime',
    -- Display TotalFare in German currency
	FORMAT(SUM(TotalAmount), 'c', 'de-de') AS 'TotalFare'
FROM YellowTripData
INNER JOIN TaxiZoneLookup AS Zone 
ON PULocationID = Zone.LocationID 
GROUP BY
	CAST(PickupDate as date),
    Zone.Borough 
ORDER BY
	CAST(PickupDate as date),
    Zone.Borough;

/*
NYC Borough statistics SP
It's time to apply what that you have learned in this course and write a stored procedure to solve the first objective of the Taxi Ride business case. 
Calculate AvgFarePerKM, RideCount and TotalRideMin for each NYC borough and weekday.
After discussion with stakeholders, you should omit records where the TripDistance is zero.
*/
CREATE OR ALTER PROCEDURE dbo.cuspBoroughRideStats
AS
BEGIN
SELECT
    -- Calculate the pickup weekday
	DATENAME(weekday, PickupDate) AS 'Weekday',
    -- Select the Borough
	Zone.Borough AS 'PickupBorough',
    -- Display AvgFarePerKM as German currency
	FORMAT(AVG(dbo.ConvertDollar(TotalAmount, .88)/dbo.ConvertMiletoKM(TripDistance)), 'c', 'de-de') AS 'AvgFarePerKM',
    -- Display RideCount in the German format
	FORMAT(COUNT (ID), 'n', 'de-de') AS 'RideCount',
    -- Display TotalRideMin in the German format
	FORMAT(SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60, 'n', 'de-de') AS 'TotalRideMin'
FROM YellowTripData
INNER JOIN TaxiZoneLookup AS Zone 
ON PULocationID = Zone.LocationID
-- Only include records where TripDistance is greater than 0
WHERE TripDistance > 0
-- Group by pickup weekday and Borough
GROUP BY DATENAME(WEEKDAY, PickupDate), Zone.Borough
ORDER BY CASE WHEN DATENAME(WEEKDAY, PickupDate) = 'Monday' THEN 1
	     	  WHEN DATENAME(WEEKDAY, PickupDate) = 'Tuesday' THEN 2
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Wednesday' THEN 3
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Thursday' THEN 4
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Friday' THEN 5
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Saturday' THEN 6
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Sunday' THEN 7 END,  
		 SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60
DESC
END;

/*
NYC Borough statistics results
Let's see the results of the dbo.cuspBoroughRideStats stored procedure you just created.
*/
-- Create SPResults
DECLARE @SPResults TABLE(
  	-- Create Weekday
	Weekday 		nvarchar(30),
    -- Create Borough
	Borough 		nvarchar(30),
    -- Create AvgFarePerKM
	AvgFarePerKM 	nvarchar(30),
    -- Create RideCount
	RideCount		nvarchar(30),
    -- Create TotalRideMin
	TotalRideMin	nvarchar(30))

-- Insert the results into @SPResults
INSERT INTO @SPResults
-- Execute the SP
EXEC dbo.cuspBoroughRideStats

-- Select all the records from @SPresults 
SELECT * 
FROM @SPResults;

/*
Pickup locations by shift
It's time to solve the second objective of the business case. 
What are the AvgFarePerKM, RideCount and TotalRideMin for each pickup location and shift within a NYC Borough?
*/
-- Create the stored procedure
CREATE PROCEDURE dbo.cuspPickupZoneShiftStats
	-- Specify @Borough parameter
	@Borough nvarchar(30)
AS
BEGIN
SELECT
	DATENAME(WEEKDAY, PickupDate) as 'Weekday',
    -- Calculate the shift number
	dbo.GetShiftNumber(DATEPART(hour, PickupDate)) as 'Shift',
	Zone.Zone as 'Zone',
	FORMAT(AVG(dbo.ConvertDollar(TotalAmount, .77)/dbo.ConvertMiletoKM(TripDistance)), 'c', 'de-de') AS 'AvgFarePerKM',
	FORMAT(COUNT (ID),'n', 'de-de') as 'RideCount',
	FORMAT(SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60, 'n', 'de-de') as 'TotalRideMin'
FROM YellowTripData
INNER JOIN TaxiZoneLookup as Zone on PULocationID = Zone.LocationID 
WHERE
	dbo.ConvertMiletoKM(TripDistance) > 0 AND
	Zone.Borough = @Borough
GROUP BY
	DATENAME(WEEKDAY, PickupDate),
    -- Group by shift
	dbo.GetShiftNumber(DATEPART(hour, PickupDate)),  
	Zone.Zone
ORDER BY CASE WHEN DATENAME(WEEKDAY, PickupDate) = 'Monday' THEN 1
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Tuesday' THEN 2
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Wednesday' THEN 3
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Thursday' THEN 4
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Friday' THEN 5
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Saturday' THEN 6
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Sunday' THEN 7 END,
         -- Order by shift
         dbo.GetShiftNumber(DATEPART(hour, PickupDate)),
         SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60 DESC
END;

/*
Pickup locations by shift results
Let's see the AvgFarePerKM,RideCount and TotalRideMin for the pickup locations within Manhattan during the different driver shifts of each weekday.
*/
-- Create @Borough
DECLARE @Borough AS nvarchar(30) = 'Manhattan'
-- Execute the SP
EXEC dbo.cuspPickupZoneShiftStats
    -- Pass @Borough
	@Borough = @Borough;