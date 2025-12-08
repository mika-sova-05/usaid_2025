


-- **********************************************************************************************
-- *********************** DATA BASE DESIGN *****************************************************
-- **********************************************************************************************


-- ***************************** Creating of a DB ************************************************

CREATE DATABASE Usaid_2      --  
ON
(NAME = USAID_2_Data,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Usaid_2.mdf',
SIZE = 5000MB,
FILEGROWTH = 50MB)
LOG ON
(NAME = USAID_2_Log,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Usaid_Log_2.ldf',
SIZE = 5000MB,
FILEGROWTH = 50MB);
-- DROP DATABASE Usaid_2


-- Let's have a look at current .mdf and .ldf files' characteristics:
SELECT *
FROM sys.database_files;


-- Let's have a look at current .mdf and .ldf files' characteristics:
SELECT size * 8/1024 AS size_MB
FROM sys.database_files
WHERE type_desc = 'ROWS';

SELECT size * 8/1024 AS size_MB
FROM sys.database_files
WHERE type_desc = 'LOG';



-- ***************************** DB Design ************************************************
USE Usaid_2; 
GO


-- Let's import a table named 'to_pandas' from Tables_clsn.xlsx file through Wizard (Db Name -> Tasks -> Import Flat File).
-- Since the ending of a file name is '$' , let's get rid of it.
-- EXEC sp_rename 'to_pandas$', 'to_pandas'
-- Check-Up:
-- SELECT * FROM [dbo].[to_pandas]

-- Now let's create all the tables' structures CAREFULLY and MANUALLY!


-- ***** 1 TABLE 'region'  

IF OBJECT_ID('dbo.region') IS NOT NULL DROP TABLE dbo.region;

CREATE TABLE region (
	[region_id] BIGINT NOT NULL,
	[region_name] NVARCHAR(max),
	PRIMARY KEY ([region_id])
);

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

BULK INSERT dbo.region
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\region.csv'
WITH (FORMAT = 'CSV');

SELECT * FROM dbo.region

EXEC sp_help region



-- ************** 2 TABLE 'income_group'  ***************************************************************

IF OBJECT_ID('dbo.[income_group]') IS NOT NULL DROP TABLE dbo.[income_group];

CREATE TABLE dbo.[income_group] (
	[income_group_id] BIGINT NOT NULL,
	[income_group_name] NVARCHAR(max),
	[income_group_acronym] NVARCHAR(max),
	PRIMARY KEY ([income_group_id])
);

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

BULK INSERT dbo.[income_group]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\income_group.csv'
WITH (FORMAT = 'CSV');

SELECT * FROM dbo.[income_group]




-- ************** 3 TABLE 'country'  ***************************************************************

IF OBJECT_ID('dbo.country') IS NOT NULL DROP TABLE dbo.country;

CREATE TABLE dbo.country (
	[country_id] BIGINT NOT NULL,
	[country_code] NVARCHAR(max),
	[country_name] NVARCHAR(max),
	[region_id] BIGINT,
	[income_group_id] BIGINT
	, PRIMARY KEY ([country_id])
	--, FOREIGN KEY ([region_id]) REFERENCES dbo.Region([region_id])
	--, FOREIGN KEY ([income_group_id]) REFERENCES dbo.[income_group]([income_group_id])
);


BULK INSERT dbo.country
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\country.csv'
WITH (FORMAT = 'CSV');

SELECT * FROM dbo.country




-- ************** 4 TABLE 'transaction_type'  ***************************************************************

IF OBJECT_ID('dbo.[transaction_type]') IS NOT NULL DROP TABLE dbo.[transaction_type]

CREATE TABLE dbo.[transaction_type] (
	[transaction_type_id] BIGINT PRIMARY KEY,
	[transaction_type_name] NVARCHAR(max)
	);

INSERT INTO dbo.[transaction_type] ([transaction_type_id], [transaction_type_name])
VALUES (2, 'Obligations'),
	   (3, 'Disbursements');

-- i've found new transaction types in other reports a few days later:
INSERT INTO dbo.[transaction_type]([transaction_type_id], [transaction_type_name])
VALUES (1, 'Appropriated and Planned'),
	   (18, 'President''s Budget Requests');

SELECT * FROM dbo.[transaction_type]




-- ************** 5 TABLE 'managing_agency'  ***************************************************************

IF OBJECT_ID('dbo.[managing_agency]') IS NOT NULL DROP TABLE dbo.[managing_agency]

CREATE TABLE dbo.[managing_agency] (
	[managing_agency_id] BIGINT NOT  NULL PRIMARY KEY,
	[managing_agency_acronym] NVARCHAR(max),
	[managing_agency_name] NVARCHAR(max)
	);

BULK INSERT dbo.[managing_agency]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\managing_agency.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[managing_agency]



-- ************** 6 TABLE 'funding_agency'  ***************************************************************

IF OBJECT_ID('dbo.[funding_agency]') IS NOT NULL DROP TABLE dbo.[funding_agency]

CREATE TABLE dbo.[funding_agency] (
	[funding_agency_id] BIGINT NOT NULL PRIMARY KEY,
	[funding_agency_acronym] NVARCHAR(max),
	[funding_agency_name] NVARCHAR(max)
	);

BULK INSERT dbo.[funding_agency]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\funding_agency.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[funding_agency]




-- *********** 7 TABLE 'funding_account'  ********************************************************

IF OBJECT_ID('dbo.[funding_account]') IS NOT NULL DROP TABLE dbo.[funding_account]

CREATE TABLE funding_account(
	funding_account_id NVARCHAR(max),
	funding_account_name NVARCHAR(max),
	funding_agency_id BIGINT
);

BULK INSERT dbo.[funding_account]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\funding_account.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM funding_account;

-- Since a native identifier is of text type (kind of 72x1037), let's create a new one with integer type
ALTER TABLE funding_account
ADD funding_account_id1 BIGINT;

-- Fulfilling a new column with values from cte
WITH cte AS (
	SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as for_funding_account_id1    
	FROM funding_account
)
UPDATE funding_account
SET funding_account.funding_account_id1 = cte.for_funding_account_id1
FROM funding_account 
INNER JOIN 
	cte
ON funding_account.funding_account_id = cte.funding_account_id AND
	funding_account.funding_account_name = cte.funding_account_name AND
	funding_account.funding_agency_id = cte.funding_agency_id ;
	

-- In case a trigger banning data type change is active, let's disable it:
IF EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange'
		   AND parent_class_desc = 'DATABASE')
BEGIN 
	DISABLE TRIGGER BanOnDTChange ON DATABASE;
END;

-- Changing data type of a new column
ALTER TABLE funding_account
ALTER COLUMN funding_account_id1 BIGINT NOT NULL;

-- Enabling the trigge back
IF EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange'
		   AND parent_class_desc = 'DATABASE')
BEGIN 
	ENABLE TRIGGER BanOnDTChange ON DATABASE;
END;


--ALTER TABLE funding_account
--ADD FOREIGN KEY (funding_agency_id) REFERENCES funding_agency(funding_agency_id);

ALTER TABLE funding_account
ADD CONSTRAINT funding_account_PK PRIMARY KEY (funding_account_id1);


--ALTER TABLE funding_account -- firstly delete PK, only after delete a column
--DROP funding_account_pk;

SELECT * FROM funding_account;
EXEC sp_help 'funding_account';




-- *************************** 8 TABLE 'international_category' ******************************************

IF OBJECT_ID('dbo.[international_category]') IS NOT NULL DROP TABLE dbo.[international_category]

CREATE TABLE dbo.[international_category] (
	[international_category_id] BIGINT PRIMARY KEY,
	[international_category_name] NVARCHAR(max)
	);

BULK INSERT dbo.[international_category]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\international_category.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[international_category]




-- *********** 9 TABLE 'international_sector'  ********************************************************

IF OBJECT_ID('dbo.[international_sector]') IS NOT NULL DROP TABLE dbo.[international_sector]

CREATE TABLE dbo.[international_sector] (
	[international_sector_id] BIGINT NOT NULL PRIMARY KEY,
	[international_sector_name] NVARCHAR(max),
	[international_category_id] BIGINT
	);

BULK INSERT dbo.[international_sector]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\international_sector.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[international_sector]

--ALTER TABLE dbo.[Sectors]
--ADD FOREIGN KEY ([Category ID]) REFERENCES dbo.[Categories]([Category ID])



-- ************** 10 TABLE 'international_purpose'  ***************************************************************

IF OBJECT_ID('dbo.[international_purpose]') IS NOT NULL DROP TABLE dbo.[international_purpose]

CREATE TABLE dbo.[international_purpose] (
	[international_purpose_id] BIGINT NOT NULL PRIMARY KEY,
	[international_purpose_name] NVARCHAR(max),
	[international_sector_id] BIGINT
	);

BULK INSERT dbo.[international_purpose]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\international_purpose.csv'
WITH (FORMAT='CSV')

SELECT * FROM dbo.[international_purpose]




-- ************** 11 TABLE 'foreign_assistance_objective'  ***************************************************************

IF OBJECT_ID('dbo.[foreign_assistance_objective]') IS NOT NULL DROP TABLE dbo.[foreign_assistance_objective]

CREATE TABLE dbo.[foreign_assistance_objective] (
	[foreign_assistance_objective_id] BIGINT NOT NULL PRIMARY KEY,
	[foreign_assistance_objective_name] NVARCHAR(max)
	);

INSERT INTO dbo.[foreign_assistance_objective] ([foreign_assistance_objective_id], [foreign_assistance_objective_name])
VALUES (1, 'Economic'),
	   (2, 'Military');

SELECT * FROM dbo.[foreign_assistance_objective]



-- *************************** 12 TABLE 'us_category' ******************************************

IF OBJECT_ID('dbo.[us_category]') IS NOT NULL DROP TABLE dbo.[us_category]

CREATE TABLE dbo.[us_category] (
	[us_category_id] BIGINT NOT NULL PRIMARY KEY,
	[us_category_name] NVARCHAR(max)
	);

BULK INSERT dbo.[us_category]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\us_category.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[us_category]




-- *********** 13 TABLE 'us_sector'  ********************************************************

IF OBJECT_ID('dbo.[us_sector]') IS NOT NULL DROP TABLE dbo.[us_sector]

CREATE TABLE dbo.[us_sector] (
	[us_sector_id] BIGINT NOT NULL PRIMARY KEY,
	[us_sector_name] NVARCHAR(max),
	[us_category_id] BIGINT
	);

BULK INSERT dbo.[us_sector]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\us_sector.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[us_sector]



-- *************************** 14 TABLE 'aid_type_group' ******************************************

IF OBJECT_ID('dbo.[aid_type_group]') IS NOT NULL DROP TABLE dbo.[aid_type_group]

CREATE TABLE dbo.[aid_type_group] (
	[aid_type_group_id] BIGINT NOT NULL PRIMARY KEY,
	[aid_type_group_name] NVARCHAR(max)
	);

BULK INSERT dbo.[aid_type_group]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\aid_type_group.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[aid_type_group]





-- *********** 15 TABLE 'aid_type'  ********************************************************

IF OBJECT_ID('dbo.[aid_type]') IS NOT NULL DROP TABLE dbo.[aid_type]

CREATE TABLE dbo.[aid_type] (
	[aid_type_id] BIGINT NOT NULL PRIMARY KEY,
	[aid_type_name] NVARCHAR(max),
	[aid_type_group_id] BIGINT
	);

BULK INSERT dbo.[aid_type]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\aid_type.csv'
WITH (FORMAT = 'CSV')

SELECT * FROM dbo.[aid_type]




-- ************** TABLE 'actions'  ***************************************************************


SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
SELECT * FROM INFORMATION_SCHEMA.COLUMNS


IF OBJECT_ID('dbo.[actions]') IS NOT NULL DROP TABLE dbo.[actions]

CREATE TABLE dbo.[actions] ( --  When using BULK INSERT, the order of columns in a csv file must exactly match the order of columns in actions table
	[actions_id] BIGINT PRIMARY KEY,
	[country_id] BIGINT,
	[managing_agency_id] BIGINT,
	[us_sector_id] BIGINT,
	[funding_account_id] NVARCHAR(max),   -- !!!!
	[international_purpose_id] BIGINT,
	[foreign_assistance_objective_id] BIGINT,
	[aid_type_id] BIGINT,
	[activity_id] BIGINT,
	[activity_name] NVARCHAR(max),
	[activity_description]  NVARCHAR(max),
	[transaction_type_id] BIGINT,
	[fiscal_year] DATETIME2(7),
	[transaction_date] DATETIME2(7),
	[current_dollar_amount] FLOAT,
	[constant_dollar_amount] FLOAT,
	[activity_budget_amount] FLOAT,
	[activity_start_date] DATETIME2(7),
	[activity_end_date] DATETIME2(7)
	);

BULK INSERT dbo.[actions]
FROM 'C:\Users\User\Desktop\Ëèêà\For_a_while\DS\Projects\US_foreign_aid\Prep_for_GIT\From_pandas\actions.csv'
WITH (FORMAT = 'CSV')

SELECT TOP (100) * FROM dbo.[actions]


--ALTER TABLE actions
--DROP COLUMN [funding_agency_id] ;
--SELECT * FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'actions'


EXEC sp_rename 'actions.funding_account_id', 'funding_account_id1', 'COLUMN'

UPDATE actions
SET funding_account_id1 = fa.funding_account_id1
FROM actions a
	INNER JOIN funding_account fa
	ON a.funding_account_id1 = fa.funding_account_id;


IF EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange'
		   AND parent_class_desc = 'DATABASE')
BEGIN 
	DISABLE TRIGGER BanOnDTChange ON DATABASE;
END;


ALTER TABLE actions
ALTER COLUMN funding_account_id1 BIGINT;


IF EXISTS (SELECT * 
		   FROM sys.triggers
		   WHERE name = 'BanOnDTChange'
		   AND parent_class_desc = 'DATABASE')
BEGIN 
	ENABLE TRIGGER BanOnDTChange ON DATABASE;
END;

--ALTER TABLE actions
--ADD CONSTRAINT actions_funding_account_fk
--FOREIGN KEY (funding_account_id1) REFERENCES funding_account(funding_account_id1);



--- ***********************    ADDING FOREIGN KEYS   ************************************

SELECT *
FROM sys.foreign_keys
ORDER BY name;

SELECT *
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS


-- *** country_region_fk ***

ALTER TABLE country
ADD CONSTRAINT country_region_fk
FOREIGN KEY (region_id) REFERENCES region(region_id);
--IF OBJECT_ID('country_region_fk') IS NOT NULL ALTER TABLE region DROP CONSTRAINT country_region_fk


-- *** country_income_group_fk ***
ALTER TABLE country
ADD CONSTRAINT country_income_group_fk
FOREIGN KEY (income_group_id) REFERENCES income_group(income_group_id);


-- *** funding_account_funding_agency_fk ***
--IF OBJECT_ID('funding_account_funding_agency_fk') IS NOT NULL ALTER TABLE funding_account DROP CONSTRAINT funding_account_funding_agency_fk

ALTER TABLE funding_account
ADD CONSTRAINT funding_account_funding_agency_fk
FOREIGN KEY (funding_agency_id) REFERENCES funding_agency(funding_agency_id);


-- *** actions_transaction_type_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_transaction_type_fk
FOREIGN KEY (transaction_type_id) REFERENCES transaction_type(transaction_type_id);


-- *** actions_foreign_assistance_objective_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_foreign_assistance_objective_fk
FOREIGN KEY (foreign_assistance_objective_id) REFERENCES foreign_assistance_objective(foreign_assistance_objective_id);


-- *** actions_managing_agency_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_managing_agency_fk
FOREIGN KEY (managing_agency_id) REFERENCES managing_agency(managing_agency_id);


-- *** aid_type_aid_type_group_fk ***
ALTER TABLE aid_type
ADD CONSTRAINT aid_type_aid_type_group_fk
FOREIGN KEY (aid_type_group_id) REFERENCES aid_type_group(aid_type_group_id);


-- *** actions_aid_type_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_aid_type_fk
FOREIGN KEY (aid_type_id) REFERENCES aid_type(aid_type_id);


-- *** international_sector_international_category_fk ***
ALTER TABLE international_sector
ADD CONSTRAINT international_sector_international_category_fk
FOREIGN KEY (international_category_id) REFERENCES international_category(international_category_id);


-- *** international_purpose_international_sector_fk ***
ALTER TABLE international_purpose
ADD CONSTRAINT international_purpose_international_sector_fk
FOREIGN KEY (international_sector_id) REFERENCES international_sector(international_sector_id);


-- *** us_sector_us_category_fk ***
ALTER TABLE us_sector
ADD CONSTRAINT us_sector_us_category_fk
FOREIGN KEY (us_category_id) REFERENCES us_category(us_category_id);


-- *** actions_us_sector_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_us_sector_fk
FOREIGN KEY (us_sector_id) REFERENCES us_sector(us_sector_id);


-- *** actions_country_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_country_fk
FOREIGN KEY (country_id) REFERENCES country(country_id);


-- *** actions_funding_account_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_funding_account_fk
FOREIGN KEY (funding_account_id1) REFERENCES funding_account(funding_account_id1);



-- *** actions_international_purpose_fk ***
ALTER TABLE actions
ADD CONSTRAINT actions_international_purpose_fk
FOREIGN KEY (international_purpose_id) REFERENCES international_purpose(international_purpose_id);




-- ************************ Adressing issues with income_group absence for some countries ************************

-- Let's insert a new column income_group_id_1 with NULLS substituted by 0 in a country_table.
-- !!! SO, ZERO income group means UNDEFINED income group!!!

SELECT *
FROM country;

SELECT DISTINCT income_group_id
FROM country;

ALTER TABLE country
ADD income_group_id_1 BIGINT;

UPDATE country
SET income_group_id_1 = (CASE WHEN income_group_id IS NULL THEN 0
						ELSE income_group_id
						END)


SELECT *
FROM income_group;

INSERT income_group
VALUES (0, 'Undefined', 'Undefined');

ALTER TABLE country
DROP CONSTRAINT country_income_group_fk;

ALTER TABLE country
ADD CONSTRAINT country_income_group_fk
FOREIGN KEY (income_group_id_1)
REFERENCES income_group(income_group_id);