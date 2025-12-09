
USE Usaid_2;
GO


-- ******************************************************************************************************
-- ************************************ TRIGGERS AND LOGGING ********************************************
-- ******************************************************************************************************


-- ************************************** Let's check all current active and disabled triggers  **********
SELECT DB_NAME();

SELECT *
FROM sys.triggers;

SELECT *
FROM sys.objects
WHERE type_desc LIKE '%TRIGGER%'
ORDER BY name;

GO

-- ************************************** Ban on Deleting Tables/Views/Procedures/Functions/Triggers *******

-- Let's create a trigger preventing users from deleting DB major objects:
DECLARE @sql NVARCHAR(MAX)
SET @sql = '	CREATE TRIGGER BanOnDeleting
	ON DATABASE
	FOR DROP_TABLE, DROP_VIEW, DROP_PROCEDURE, DROP_TRIGGER, DROP_FUNCTION
	AS
	BEGIN
		PRINT ''''
		PRINT ''!!! BETTER SAFE THAN SORRY (BanOnDeleting) !!!''
		PRINT ''''
		ROLLBACK;
	END'

PRINT(@sql);

IF EXISTS (SELECT name
		   FROM sys.triggers
		   WHERE name = 'BanOnDeleting' AND is_disabled = 1)
BEGIN
	ENABLE TRIGGER BanOnDeleting ON DATABASE;
END
ELSE IF NOT EXISTS (SELECT name
		   FROM sys.triggers
		   WHERE name = 'BanOnDeleting')
BEGIN
	EXEC sp_executesql @sql;
END


-- CHECK-UP
GO
CREATE FUNCTION [dbo].[TestForTriggersFunc] ()
RETURNS NVARCHAR(30)
AS
BEGIN 
	RETURN 'Test value';
END;
GO
DROP FUNCTION [dbo].[TestForTriggersFunc];
SELECT dbo.TestForTriggersFunc();



-- ************************************** Ban on Changing Columns ******************************************

-- Let's create a trigger preventing users from changing tables columns:
DECLARE @sql NVARCHAR(MAX)
SET @sql = 'CREATE TRIGGER BanOnDTChange
	ON DATABASE
	FOR ALTER_TABLE
	AS 
	BEGIN
		DECLARE @Event XML
		SET @Event = EVENTDATA()

		IF @Event.value(''(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]'', ''NVARCHAR(MAX)'') LIKE ''%ALTER COLUMN%''
		BEGIN 
			PRINT ''''
			PRINT ''!!! BETTER SAFE THAN SORRY (BanOnDTChange)!!!''
			PRINT ''''
			ROLLBACK;	
		END;
	END;
	'

IF EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange' AND is_disabled = 1)
BEGIN
	ENABLE TRIGGER BanOnDTChange ON DATABASE;
END
ELSE IF NOT EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange')
BEGIN
	EXEC sp_executesql @sql;
END


-- CHECK-UP
DECLARE @sql NVARCHAR(1000),
        @sql_name NVARCHAR(1000);

SET @sql_name = 'TestForTriggers_' + REPLACE(REPLACE(CAST(CURRENT_TIMESTAMP AS NVARCHAR(1000)), ' ', '_'), ':', '_');
--PRINT @sql_name;

SET @sql = '
CREATE TABLE [' + @sql_name + '] (
    cln_name_1 INT NULL,
    cln_name_2 INT NULL
);
INSERT INTO [' + @sql_name + '] VALUES (NULL, NULL);
';

--PRINT @sql;
EXEC sp_executesql @sql;

EXEC('SELECT * FROM [' + @sql_name + ']')

EXEC('ALTER TABLE [' + @sql_name + ']' + 
'ALTER COLUMN cln_name_2 NVARCHAR(100)')

-- ENABLE TRIGGER BanOnDTChange ON DATABASE;
-- DROP TRIGGER BanOnDTChange ON DATABASE;
-- DROP TRIGGER BanOnDeleting ON DATABASE;



-- ********************************  LOGGING DATA MODIFICATIONS IN ALL 16 TABLES ************************************

-- Let's import a basic table 'to_pandas' (from xlsx/csv) which contains the major fact table (actions) and all the catalogues (15 tables)
-- It will be useful for creating Log Tables for all 16 tables.

CREATE TABLE to_pandas (
	actions NVARCHAR(255) NULL,
	country NVARCHAR(255) NULL,
	region NVARCHAR(255) NULL,
	income_group NVARCHAR(255) NULL,
	managing_agency NVARCHAR(255) NULL,
	international_category NVARCHAR(255) NULL,
	international_sector NVARCHAR(255) NULL,
	international_purpose NVARCHAR(255) NULL,
	us_category NVARCHAR(255) NULL,
	us_sector NVARCHAR(255) NULL,
	funding_account NVARCHAR(255) NULL,
	funding_agency NVARCHAR(255) NULL,
	foreign_assistance_objective NVARCHAR(255) NULL,
	aid_type_group NVARCHAR(255) NULL,
	transaction_type NVARCHAR(255) NULL,
	aid_type NVARCHAR(255) NULL
);

BULK INSERT to_pandas
FROM 'C:\Users\User\Desktop\ห่๊เ\For_a_while\DS\Projects\US_foreign_aid\For_GIT\USAID_DB_DESIGN\to_pandas.csv'
WITH (FORMAT = 'CSV', 
	 FIRSTROW = 2,
	 FIELDTERMINATOR = ';');



-- Now that we've prepared 'to_pandas' table, we can create Log Tables for all 16 tables.
GO
DECLARE @to_pandas_object_id INT;
SELECT @to_pandas_object_id = (SELECT OBJECT_ID 
							   FROM sys.tables 
							   WHERE name = 'to_pandas');

DECLARE @i INT = 1;
DECLARE @sql NVARCHAR(1000),
		@sql_1 NVARCHAR(1000);
WHILE @i < 17
BEGIN
	WITH cte1 as (
		SELECT name, ROW_NUMBER() OVER (ORDER BY name) row_num 
		FROM sys.columns
		WHERE object_id = @to_pandas_object_id
	)
	SELECT @sql_1 = 'CREATE TABLE Log_modification_' + name + ' (ID INT PRIMARY KEY IDENTITY(1,1), 
																Modification_type NVARCHAR(100),
																Modification_date DATE,
																Modified_table NVARCHAR(100),
																Modified_tables_PK INT,
																Old_data NVARCHAR(MAX),
																New_data NVARCHAR(MAX));'
	FROM cte1
	WHERE row_num = @i;

	--PRINT @sql;
	EXEC sp_executesql @sql_1

	SET @i += 1
END;



-- ****************************************  TRIGGERS FOR INSERT COMMAND   ****************************************** 

-- TRIGGER FOR INSERT COMMAND  (individual table, example)
GO
CREATE TRIGGER LogInsert
ON [us_sector]
AFTER INSERT
AS
BEGIN
	INSERT INTO Log_modification_us_sector (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data )
	SELECT 'INSERT', GETDATE(), 'us_sector',  i.us_sector_id, '', (SELECT * FROM inserted i2 WHERE i2.us_sector_id = i.us_sector_id FOR JSON AUTO)  
	FROM inserted i
END;

-- CHECK-UP
INSERT INTO [us_sector](us_sector_id, us_sector_name, us_category_id) -- FOR TESTING PURPOSES! MUST BE DELETED AFTER TESTING!
VALUES (888, 'Counter-Terrorism_888', 1), 
	   (999, 'Counter-Terrorism_999', 1),
	   (1111, 'Counter-Terrorism_1111', 1);

SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;

DELETE FROM us_sector
WHERE us_sector_id IN (888, 999, 1111);


-- TRIGGER FOR INSERT COMMAND  (all tables)
SELECT * FROM to_pandas;

DECLARE @i INT = 1,
		@table_name NVARCHAR(100),
		@sql NVARCHAR(1000)

WHILE @i < 17
BEGIN 

	WITH cte1 as (
	SELECT sc.name as table_name, ROW_NUMBER() OVER (ORDER BY st.name) row_num
	FROM sys.columns sc 
	INNER JOIN sys.tables st
	ON sc.object_id = st.object_id
	WHERE st.name = 'to_pandas'
	)
	SELECT @table_name = table_name
	FROM cte1
	WHERE row_num = @i;

	SET @sql = '
		CREATE TRIGGER LogInsert_' + @table_name +
		' ON ' + @table_name + 
		' AFTER INSERT
		AS
		BEGIN
			INSERT INTO Log_modification_' + @table_name + ' (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data )
			SELECT ''INSERT'', GETDATE(), ''' + @table_name + ''',  i.' + @table_name + '_id, '''', (SELECT * FROM inserted i2 WHERE i2.' + @table_name + '_id = i.' + @table_name + '_id FOR JSON AUTO)  
			FROM inserted i
		END;
		'
	--PRINT @sql;
	EXEC sp_executesql @sql;

	SET @i += 1
END;


-- CHECK-UP
INSERT INTO [region](region_id, region_name) -- FOR TESTING PURPOSES! MUST BE DELETED AFTER TESTING!
VALUES (44440, 'NEW_REGION_4444'), 
	   (33330, 'NEW_REGION__3333'),
	   (22220, 'NEW_REGION__2222');
SELECT * FROM region;
SELECT * FROM Log_modification_region;

DELETE FROM region
WHERE region_id IN (44440, 33330, 22220);


-- CHECK-UP
INSERT INTO [us_sector](us_sector_id, us_sector_name, us_category_id) -- FOR TESTING PURPOSES! MUST BE DELETED AFTER TESTING!
VALUES (4444, 'Counter-Terrorism_4444', 1), 
	   (3333, 'Counter-Terrorism_333', 1),
	   (5555, 'Counter-Terrorism_222', 1);
SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;

DELETE FROM us_sector
WHERE us_sector_id IN (4444, 3333, 2222);



-- *******************************************  TRIGGERS FOR DELETE COMMAND   **************************************** 

-- TRIGGER FOR DELETE COMMAND (individual table, example)
GO
CREATE TRIGGER LogDelete
ON [us_sector]
AFTER DELETE
AS
BEGIN

	INSERT INTO Log_modification_us_sector (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data)
	SELECT 'DELETE', GETDATE(), 'us_sector', d.us_sector_id, (SELECT * FROM deleted d2 WHERE d2.us_sector_id = d.us_sector_id FOR JSON AUTO), ''
	FROM deleted d;

END;

DELETE FROM us_sector WHERE us_sector_id = 4444 OR us_sector_id = 3333;
SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;



-- TRIGGER FOR DELETE COMMAND  (all tables)
SELECT * FROM to_pandas;

DECLARE @i INT = 1,
		@table_name NVARCHAR(100),
		@sql NVARCHAR(1000)

WHILE @i < 17
BEGIN 

	WITH cte1 as (
	SELECT sc.name as table_name, ROW_NUMBER() OVER (ORDER BY st.name) row_num
	FROM sys.columns sc 
	INNER JOIN sys.tables st
	ON sc.object_id = st.object_id
	WHERE st.name = 'to_pandas'
	)
	SELECT @table_name = table_name
	FROM cte1
	WHERE row_num = @i;

	SET @sql = '
		CREATE TRIGGER LogDelete_' +  @table_name +
		' ON ' + @table_name + 
		' AFTER DELETE
		AS
		BEGIN

			INSERT INTO Log_modification_' + @table_name + ' (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data)
			SELECT ''DELETE'', GETDATE(), ''' + @table_name + ''', d.' + @table_name + '_id, (SELECT * FROM deleted d2 WHERE d2.' + @table_name + '_id = d.' + @table_name + '_id FOR JSON AUTO), ''''
			FROM deleted d;

		END;
		'
	--PRINT @sql;
	EXEC sp_executesql @sql;

	SET @i += 1
END;


-- CHECK-UP
DELETE FROM us_sector WHERE us_sector_id = 5555 OR us_sector_id = 4444;
SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;

DELETE FROM region WHERE region_id =2222 OR region_id = 4444;
SELECT * FROM region;
SELECT * FROM Log_modification_region;



-- -- *******************************************  TRIGGERS FOR UPDATE COMMAND   ***************************************

-- TRIGGER FOR UPDATE COMMAND (individual table, example)
GO 
CREATE TRIGGER LogUpdate
ON us_sector
AFTER UPDATE
AS
BEGIN
	
	INSERT INTO Log_modification_us_sector (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data)
	SELECT 'UPDATE', GETDATE(), 'us_sector', d.us_sector_id, (SELECT * FROM deleted d2 WHERE d2.us_sector_id = d.us_sector_id FOR JSON AUTO),
															 (SELECT * FROM inserted i2 WHERE i2.us_sector_id = i.us_sector_id FOR JSON AUTO)
	FROM deleted d 
	INNER JOIN inserted i 
	ON d.us_sector_id = i.us_sector_id;

END;

-- CHECK-UP
UPDATE us_sector
SET us_sector_name = 
	(CASE WHEN us_sector_id = 2222 THEN 'Counter-Terrorism_888_new'
		 WHEN us_sector_id = 3333 THEN 'Counter-Terrorism_999_new'
		 ELSE us_sector_name
	END)
WHERE us_sector_id IN (2222, 3333);
	
SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;


-- TRIGGER FOR UPDATE COMMAND  (all tables)
SELECT * FROM to_pandas;

DECLARE @i INT = 1,
		@table_name NVARCHAR(100),
		@sql NVARCHAR(1000)

WHILE @i < 17
BEGIN 

	WITH cte1 as (
	SELECT sc.name as table_name, ROW_NUMBER() OVER (ORDER BY st.name) row_num
	FROM sys.columns sc 
	INNER JOIN sys.tables st
	ON sc.object_id = st.object_id
	WHERE st.name = 'to_pandas'
	)
	SELECT @table_name = table_name
	FROM cte1
	WHERE row_num = @i;

	SET @sql = '
		CREATE TRIGGER LogUpdate_' + @table_name + 
		' ON ' + @table_name +
		' AFTER UPDATE
		AS
		BEGIN
	
			INSERT INTO Log_modification_' + @table_name + ' (Modification_type, Modification_date, Modified_table, Modified_tables_PK, Old_data, New_data)
			SELECT ''UPDATE'', GETDATE(), ''' + @table_name + ''', d.' + @table_name + '_id, (SELECT * FROM deleted d2 WHERE d2.' + @table_name + '_id = d.' + @table_name + '_id FOR JSON AUTO),
																	 (SELECT * FROM inserted i2 WHERE i2.' + @table_name + '_id = i.' + @table_name + '_id FOR JSON AUTO)
			FROM deleted d 
			INNER JOIN inserted i 
			ON d.' + @table_name + '_id = i.' + @table_name + '_id;

		END;
		'
	--PRINT @sql;
	EXEC sp_executesql @sql;

	SET @i += 1
END;



-- CHECK-UP
UPDATE us_sector
SET us_sector_name = 
	(CASE WHEN us_sector_id = 888 THEN 'Counter-Terrorism_888_new_new'
		 WHEN us_sector_id = 999 THEN 'Counter-Terrorism_999_new_new'
		 ELSE us_sector_name
	END)
WHERE us_sector_id IN (888, 999);
	
SELECT * FROM us_sector;
SELECT * FROM Log_modification_us_sector;



-- CHECK-UP
UPDATE region
SET region_name = 
	(CASE WHEN region_id = 33330 THEN 'NEW_REGION_new_new'
		 ELSE region_name
	END)
WHERE region_id  = 33330;
	
SELECT * FROM region;
SELECT * FROM Log_modification_region;


SELECT * FROM sys.triggers;