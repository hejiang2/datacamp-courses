/* 
You realized your products table doesn't have any constraint to check the data stored in its stock column. 
It makes sense that stock is always greater than or equal to 0. 
For some reason, there is a mistake in the following row. The stock is -1!
You want to prepare a script adding a constraint to the products table, so that only stocks greater than or equal to 0 are allowed.
If you add this constraint that only allows stocks greater than or equal to 0, the execution will fail because there is one row where the stock equals -1.
*/
-- Set up the TRY block
BEGIN TRY
	-- Add the constraint
	ALTER TABLE products
		ADD CONSTRAINT CHK_Stock CHECK (stock >= 0);
END TRY
-- Set up the CATCH block
BEGIN CATCH
	SELECT 'An error occurred!';
END CATCH

/*
You want to register a new buyer in your buyers table. 
This new buyer is Peter Thomson.
His e-mail is peterthomson@mail.com and his phone number is 555000100.
In your database, there is also a table called errors, in which each error is stored.
You prepare a script that controls possible errors in the insertion of this person's data. 
It also inserts those errors into the errors table.
*/
-- Set up the first TRY block
BEGIN TRY
	INSERT INTO buyers (first_name, last_name, email, phone)
		VALUES ('Peter', 'Thompson', 'peterthomson@mail.com', '555000100');
END TRY
-- Set up the first CATCH block
BEGIN CATCH
	SELECT 'An error occurred inserting the buyer! You are in the first CATCH block';
    -- Set up the nested TRY block
    BEGIN TRY
    	INSERT INTO errors 
        	VALUES ('Error inserting a buyer');
        SELECT 'Error inserted correctly!';
	END TRY
    -- Set up the nested CATCH block
    BEGIN CATCH
    	SELECT 'An error occurred inserting the error! You are in the nested CATCH block';
    END CATCH 
END CATCH

/*
For every month, you want to know the total amount of money you earned in your bike store.
Instead of reviewing every order line, you thought it would be better to prepare a script that computes it and displays the results.
While writing the script, you made a mistake. As you can see, the operation 'Total: ' + SUM(price * quantity) AS total is missing a cast conversion, causing an error.
*/
-- Using error functions
-- Set up the TRY block
BEGIN TRY	
	SELECT 'Total: ' + SUM(price * quantity) AS total
	FROM orders  
END TRY
-- Set up the CATCH block
BEGIN CATCH
	-- Show error information.
	SELECT  ERROR_NUMBER() AS number,  
        	ERROR_SEVERITY() AS severity_level,  
        	ERROR_STATE() AS state,
        	ERROR_LINE() AS line,  
        	ERROR_MESSAGE() AS message; 	
END CATCH 

/*
You received some new electric bikes in your store, so you need to update the stock.
You want to register that you received 2 Trek Powerfly 5 - 2018 bikes with a price of $3499.99 each, and 3 New Power K- 2018 bikes at $1999.99 each.
You try to insert the products in the database because you think they are new models. 
However, you forgot you already have the first one in stock. 
Luckily, the products table has a constraint requiring every product name to be unique.
You prepare a script controlling possible errors in the insertions. 
You also want to insert possible errors in a table called errors, and, if something fails when inserting the error, show the error number and error message.
*/
BEGIN TRY
    INSERT INTO products (product_name, stock, price) 
    VALUES	('Trek Powerfly 5 - 2018', 2, 3499.99),   		
    		('New Power K- 2018', 3, 1999.99)		
END TRY
-- Set up the outer CATCH block
BEGIN CATCH
	SELECT 'An error occurred inserting the product!';
    -- Set up the inner TRY block
    BEGIN TRY
    	-- Insert the error
    	INSERT INTO errors 
        	VALUES ('Error inserting a product');
    END TRY    
    -- Set up the inner CATCH block
    BEGIN CATCH
    	-- Show number and message error
    	SELECT 
        	ERROR_LINE() AS line,	   
			ERROR_MESSAGE() AS message; 
    END CATCH    
END CATCH

/*
You need to select a product from the products table using a given product_id.
If the select statement doesn't find any product, you want to raise an error using the RAISERROR statement. 
You also need to catch possible errors in the execution.
*/
BEGIN TRY
    DECLARE @product_id INT = 5;
    IF NOT EXISTS (SELECT * FROM products WHERE product_id = @product_id)
        RAISERROR('No product with id %d.', 11, 1, @product_id);
    ELSE 
        SELECT * FROM products WHERE product_id = @product_id;
END TRY
-- Catch the error
BEGIN CATCH
	-- Select the error message
	SELECT ERROR_MESSAGE();
END CATCH   

-- THROW without parameters
/*
You want to prepare a stored procedure to insert new products in the database. 
In that stored procedure, you want to insert the possible errors in a table called errors, and after that, re-throw the original error.
*/
CREATE PROCEDURE insert_product
  @product_name VARCHAR(50),
  @stock INT,
  @price DECIMAL

AS

BEGIN TRY
	INSERT INTO products (product_name, stock, price)
		VALUES (@product_name, @stock, @price);
END TRY
-- Set up the CATCH block
BEGIN CATCH
	-- Insert the error and end the statement with a semicolon
    INSERT INTO errors VALUES ('Error inserting a product');
    -- Re-throw the error
	THROW; 
END CATCH

-- Executing a stored procedure that throws an error
/*
You need to insert a new product using the stored procedure you created in the previous exercise:
CREATE PROCEDURE insert_product
  @product_name VARCHAR(50),
  @stock INT,
  @price DECIMAL

AS

BEGIN TRY
    INSERT INTO products (product_name, stock, price)
        VALUES (@product_name, @stock, @price);
END TRY
BEGIN CATCH    
    INSERT INTO errors VALUES ('Error inserting a product');  
    THROW;  
END CATCH
You want to register that you received 3 Super bike bikes with a price of $499.99. 
You need to catch the possible errors generated in the execution of the stored procedure, showing the original error message.
*/
BEGIN TRY
	-- Execute the stored procedure
	EXEC insert_product
    	-- Set the values for the parameters
    	@product_name = 'Super bike',
        @stock = 3,
        @price = 499.99;
END TRY
-- Set up the CATCH block
BEGIN CATCH
	-- Select the error message
	THROW SELECT ERROR_MESSAGE();
END CATCH

-- THROW with parameters
/* 
You need to prepare a script to select all the information of a member from the staff table using a given staff_id.
If the select statement doesn't find any member, you want to throw an error using the THROW statement.
You need to warn there is no staff member with such id.
*/
-- Set @staff_id to 4
DECLARE @staff_id INT = 4;

IF NOT EXISTS (SELECT * FROM staff WHERE staff_id = @staff_id)
   	-- Invoke the THROW statement with parameters
	THROW 50001, 'No staff member with such id', 1;
ELSE
   	SELECT * FROM staff WHERE staff_id = @staff_id

-- Concatenating the message
/*
You need to prepare a script to select all the information about the members from the staff table using a given first_name.
If the select statement doesn't find any member, you want to throw an error using the THROW statement.
You need to warn there is no staff member with such a name.
*/
-- Set @first_name to 'Pedro'
DECLARE @first_name NVARCHAR(20) = 'Pedro';
-- Concat the message
DECLARE @my_message NVARCHAR(500) =
	CONCAT('There is no staff member with ', @first_name, ' as the first name.');

IF NOT EXISTS (SELECT * FROM staff WHERE first_name = @first_name)
	-- Throw the error
	THROW 50000, @my_message, 1;
    
-- FORMATMESSAGE with message string
/* 
Every time you sell a bike in your store, you need to check if there is enough stock. 
You prepare a script to check it and throw an error if there is not enough stock.
Today, you sold 10 'Trek CrossRip+ - 2018' bikes, so you need to check if you can sell them.
*/
DECLARE @product_name AS NVARCHAR(50) = 'Trek CrossRip+ - 2018';
DECLARE @number_of_sold_bikes AS INT = 10;
DECLARE @current_stock INT;
-- Select the current stock
SELECT @current_stock = stock FROM products WHERE product_name = @product_name;
DECLARE @my_message NVARCHAR(500) =
	-- Customize the message
	FORMATMESSAGE('There are not enough %s bikes. You only have %d in stock.', @product_name, @number_of_sold_bikes);

IF (@current_stock - @number_of_sold_bikes < 0)
	-- Throw the error
	THROW 50000, @my_message, 1;
    
-- This time you want to add your custom error message to the sys.messages catalog, by executing the sp_addmessage stored procedure.
-- Pass the variables to the stored procedure
EXEC sp_addmessage @msgnum = 50002, @severity = 16, @msgtext = 'There are not enough %s bikes. You only have %d in stock.', @lang = N'us_english';

DECLARE @product_name AS NVARCHAR(50) = 'Trek CrossRip+ - 2018';
DECLARE @number_of_sold_bikes AS INT = 10;
DECLARE @current_stock INT;
SELECT @current_stock = stock FROM products WHERE product_name = @product_name;
DECLARE @my_message NVARCHAR(500) =
	-- Prepare the error message
	FORMATMESSAGE(50002, @product_name, @current_stock);

IF (@current_stock - @number_of_sold_bikes < 0)
	-- Throw the error
	THROW 50000, @my_message, 1;

-- Choosing when to commit or rollback a transaction
/*
The bank where you work has decided to give $100 to those accounts with less than $5,000. 
However, the bank director only wants to give that money if there aren't more than 200 accounts with less than $5,000.
You prepare a script to give those $100, and of the multiple ways of doing it, you decide to open a transaction and then update every account with a balance of less than $5,000.
After that, you check the number of the rows affected by the update, using the @@ROWCOUNT function. 
If this number is bigger than 200, you rollback the transaction. Otherwise, you commit it.
*/
-- Begin the transaction
BEGIN TRAN; 
	UPDATE accounts set current_balance = current_balance + 100
		WHERE current_balance < 5000;
	-- Check number of affected rows
	IF @@ROWCOUNT > 200 
		BEGIN 
        	-- Rollback the transaction
			ROLLBACK TRAN; 
			SELECT 'More accounts than expected. Rolling back'; 
		END
	ELSE
		BEGIN 
        	-- Commit the transaction
			COMMIT TRAN; 
			SELECT 'Updates commited'; 
		END
        
-- Checking @@TRANCOUNT in a TRY...CATCH construct
/*
The owner of account 10 has won a raffle and will be awarded $200. 
You prepare a simple script to add those $200 to the current_balance of account 10.         
You think you have written everything correctly, but you prefer to check your code.
In fact, you made a silly mistake when adding the money: SET current_balance = 'current_balance' + 200. 
You wrote 'current_balance' as a string, which generates an error.
The script you create should rollback every change if an error occurs, checking if there is an open transaction.
If everything goes correctly, the transaction should be committed, also checking if there is an open transaction.
*/
BEGIN TRY
	-- Begin the transaction
	BEGIN TRAN;
    	-- Correct the mistake
		UPDATE accounts SET current_balance = current_balance + 200
			WHERE account_id = 10;
    	-- Check if there is a transaction
		IF @@TRANCOUNT > 0     
    		-- Commit the transaction
			COMMIT TRAN;
     
	SELECT * FROM accounts
    	WHERE account_id = 10;      
END TRY
BEGIN CATCH  
    SELECT 'Rolling back the transaction'; 
    -- Check if there is a transaction
    IF @@TRANCOUNT > 0   	
    	-- Rollback the transaction
        ROLLBACK TRAN;
END CATCH

-- Using savepoints
/*
Your colleague Anita needs help.
She prepared a script that uses savepoints, but it doesn't work. 
The script marks the first savepoint, savepoint1 and then inserts the data of a customer. 
Then, the script marks another savepoint, savepoint2, and inserts the data of another customer again. 
After that, both savepoints are rolled back. 
Finally, the script marks another savepoint, savepoint3, and inserts the data of another customer.
*/
BEGIN TRAN;
	-- Mark savepoint1
	SAVE TRAN savepoint1;
	INSERT INTO customers VALUES ('Mark', 'Davis', 'markdavis@mail.com', '555909090');

	-- Mark savepoint2
    SAVE TRAN savepoint2;
	INSERT INTO customers VALUES ('Zack', 'Roberts', 'zackroberts@mail.com', '555919191');

	-- Rollback savepoint2
	ROLLBACK TRAN savepoint2;
    -- Rollback savepoint1
	ROLLBACK TRAN savepoint1;

	-- Mark savepoint3
	SAVE TRAN savepoint3;
	INSERT INTO customers VALUES ('Jeremy', 'Johnsson', 'jeremyjohnsson@mail.com', '555929292');
-- Commit the transaction
COMMIT TRAN;

-- XACT_ABORT and THROW
/*
The wealthiest customers of the bank where you work have decided to donate the 0.01% of their current_balance to a non-profit organization. 
You are in charge of preparing the script to update the customer's accounts, but you have to do it only for those accounts with a current_balance with more than $5,000,000.
The director of the bank tells you that if there aren't at least 10 wealthy customers, you shouldn't do this operation, because she wants to interview more customers.
You prepare a script, and of the multiple ways of doing it, you decide to use XACT_ABORT in combination with THROW.
This way, if the number of affected rows is less than or equal to 10, you can throw an error so that the transaction is rolled back.
*/
-- Use the appropriate setting
SET XACT_ABORT ON;
-- Begin the transaction
BEGIN TRAN; 
	UPDATE accounts set current_balance = current_balance - current_balance * 0.01 / 100
		WHERE current_balance > 5000000;
	IF @@ROWCOUNT <= 10	
    	-- Throw the error
		THROW 55000, 'Not enough wealthy customers!', 1;
	ELSE		
    	-- Commit the transaction
		COMMIT TRAN; 
        
-- Doomed transactions
/*
You want to insert the data of two new customers into the customer table. 
You prepare a script controlling that if an error occurs, the transaction rollbacks and you get the message of the error.
You want to control it using XACT_ABORT in combination with XACT_STATE.
*/        
-- Use the appropriate setting
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRAN;
		INSERT INTO customers VALUES ('Mark', 'Davis', 'markdavis@mail.com', '555909090');
		INSERT INTO customers VALUES ('Dylan', 'Smith', 'dylansmith@mail.com', '555888999');
	COMMIT TRAN;
END TRY
BEGIN CATCH
	-- Check if there is an open transaction
	IF XACT_STATE() <> 0
    	-- Rollback the transaction
		ROLLBACK TRAN;
    -- Select the message of the error
    SELECT ERROR_MESSAGE() AS Error_message;
END CATCH

-- Using the READ UNCOMMITTED isolation level
/*
A new client visits your bank to open an account.
You insert her data into your system, causing a script like this one to start running:
BEGIN TRAN

  INSERT INTO customers (first_name, last_name, email, phone)
  VALUES ('Ann', 'Ros', 'aros@mail.com', '555555555')

  DECLARE @cust_id INT = scope_identity()

  INSERT INTO accounts (account_number, customer_id, current_balance)
  VALUES ('55555555555010121212', @cust_id, 150)

COMMIT TRAN
At that moment, your marketing colleague starts to send e-mails to every customer. 
There is going to be a raffle for a car! 
The script he executes gets every customer's data, including the last customer you inserted. 
This script starts running after the first insert occurs but before the COMMIT TRAN.
*/
-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Select first_name, last_name, email and phone
SELECT
    first_name, 
    last_name, 
    email,
	phone
FROM customers;

-- Prevent dirty reads
/*
You have to analyze how many accounts have more than $50,000.
As the number of accounts is an important result, you don't want to read data modified by other transactions that haven't committed or rolled back yet.
In doing this, you prevent dirty reads. 
However, you don't need to consider having non-repeatable or phantom reads.
*/
-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Count the accounts
SELECT COUNT(*) AS number_of_accounts
FROM accounts
WHERE current_balance >= 50000;

-- Preventing non-repeatable reads
/*
You are in charge of analyzing data about your bank customers.
You prepare a script that first selects the data of every customer.
After that, your script needs to process some mathematical operations based on the result.
After that, you want to select the same data again, ensuring nothing has changed.
As this is critical, you think it is better if nobody can change anything in the customers table until you finish your analysis. 
In doing this, you prevent non-repeatable reads.
*/
-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Begin a transaction
BEGIN TRAN

SELECT * FROM customers;

-- some mathematical operations, don't care about them...

SELECT * FROM customers;

-- Commit the transaction
COMMIT TRAN

-- Prevent phantom reads in a table
/*
Today you have to analyze the data of every customer of your bank.
As this information is very important, you think about locking the complete customers table, so that nobody will be able to change anything in this table. 
In doing this, you prevent phantom reads.
You prepare a script to select that information, and with the result of this selection, you need to process some mathematical operations.
After that, you want to select the same data again, ensuring nothing has changed.
*/
-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- Begin a transaction
BEGIN TRAN

SELECT * FROM customers;

-- After some mathematical operations, we selected information from the customers table.
SELECT * FROM customers;

-- Commit the transaction
COMMIT TRAN

-- Prevent phantom reads just in some rows
/*
You need to analyze some data about your bank customers with the customer_id between 1 and 10. 
You only want to lock the rows of the customers table with the customer_id between 1 and 10.
In doing this, you guarantee nobody will be able to change these rows, and you allow other transactions to work with the rest of the table.
You need to select the customers and execute some mathematical operations again.
After that, you want to select the customers with the customer_id between 1 and 10 again, ensuring nothing has changed.
*/
-- Set the appropriate isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- Begin a transaction
BEGIN TRAN

-- Select customer_id between 1 and 10
SELECT * 
FROM customers
WHERE customer_id BETWEEN 1 AND 10;

-- After completing some mathematical operation, select customer_id between 1 and 10
SELECT * 
FROM customers
WHERE customer_id BETWEEN 1 AND 10;

-- Commit the transaction
COMMIT TRAN

-- Avoid being blocked
/*
You are trying to select every movement of account 1 from the transactions table.
When selecting that information, you are blocked by another transaction, and the result doesn't output. 
Your database is configured under the READ COMMITTED isolation level.
Can you change your select query to get the information right now without changing the isolation level? 
In doing this you can read the uncommitted data from the transactions table.
*/
SELECT *
	-- Avoid being blocked
	FROM transactions WITH (NOLOCK)
WHERE account_id = 1