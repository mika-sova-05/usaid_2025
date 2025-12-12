
Use Usaid_2;
GO


-- ******************************************************************************************************
-- ************************************ ADDING NEW DATA TO DB ********************************************
-- ******************************************************************************************************

-- When new raw data is available, our goal is to insert it to the DB. 
-- Since new values for catalogues (dimensions) may be revealed, they should be inserted first of all.
-- Secondly, new rows of data are inserted to the fact table.
-- So let's create procedures/triggers for eleminating routing insertions.


-- ************************************* Table Structure ************************************************************

-- Let's prepare a table named raw_data for receiving new data chunks

DROP TABLE IF EXISTS raw_data;

CREATE TABLE raw_data (
  id BIGINT, 
  country_id BIGINT, 
  country_code NVARCHAR(MAX), 
  country_name NVARCHAR(MAX), 
  region_id BIGINT, 
  region_name NVARCHAR(MAX), 
  income_group_id BIGINT, 
  income_group_name NVARCHAR(MAX), 
  income_group_acronym NVARCHAR(MAX), 
  managing_agency_id BIGINT, 
  managing_agency_acronym NVARCHAR(MAX), 
  managing_agency_name NVARCHAR(MAX), 
  managing_sub_agency_or_bureau BIGINT, 
  managing_sub_agency_or_bureau_1 NVARCHAR(MAX), 
  managing_sub_agency_or_bureau_2 NVARCHAR(MAX), 
  implementing_partner_category BIGINT, 
  implementing_partner_category_1 NVARCHAR(MAX), 
  implementing_partner_sub BIGINT, 
  implementing_partner_sub_1 NVARCHAR(MAX), 
  implementing_partner_id BIGINT, 
  implementing_partner_name NVARCHAR(MAX), 
  international_category_id BIGINT, 
  international_category_name NVARCHAR(MAX), 
  international_sector_code BIGINT, 
  international_sector_name NVARCHAR(MAX), 
  international_purpose_code BIGINT, 
  international_purpose_name NVARCHAR(MAX), 
  us_category_id BIGINT, 
  us_category_name NVARCHAR(MAX), 
  us_sector_id BIGINT, 
  us_sector_name NVARCHAR(MAX), 
  funding_account_id NVARCHAR(MAX), 
  funding_account_name NVARCHAR(MAX), 
  funding_agency_id BIGINT, 
  funding_agency_name NVARCHAR(MAX), 
  funding_agency_acronym NVARCHAR(MAX), 
  foreign_assistance_objective BIGINT, 
  foreign_assistance_objective_1 NVARCHAR(MAX), 
  aid_type_group_id BIGINT, 
  aid_type_group_name NVARCHAR(MAX), 
  activity_id BIGINT, 
  submission_id BIGINT, 
  activity_name NVARCHAR(MAX), 
  activity_description NVARCHAR(MAX), 
  activity_project_number NVARCHAR(MAX), 
  transaction_type_id BIGINT, 
  transaction_type_name NVARCHAR(MAX), 
  fiscal_year DATETIME2, 
  transaction_date DATETIME2, 
  current_dollar_amount FLOAT, 
  constant_dollar_amount FLOAT, 
  aid_type_id BIGINT, 
  aid_type_name NVARCHAR(MAX), 
  activity_budget_amount NVARCHAR(MAX), 
  submission_activity_id BIGINT, 
  activity_start_date DATETIME2, 
  activity_end_date DATETIME2
);


-- If new data chunk comes from csv file
BULK INSERT raw_data 
FROM N'C:\Users\User\Desktop\ห่๊เ\For_a_while\DS\Projects\US_foreign_aid\DB_SQL_SERVER_1\raw_data_insert_20251212.csv'
WITH (FORMAT = 'CSV',
	  FIRE_TRIGGERS); --  !!! TRIGGER WILL NOT FIRE WITHOUT THIS OPTION !!!


-- If new data chunk is being added manually
INSERT INTO raw_data (id,
					  us_sector_id,  
					  us_sector_name, 
					  us_category_id, 
					  us_category_name,
					  aid_type_group_id,  
					  aid_type_group_name, 
					  aid_type_id, 
					  aid_type_name,
					  international_category_id,
					  international_category_name,
					  international_sector_code,
					  international_sector_name,
					  international_purpose_code,
					  international_purpose_name,
					  transaction_type_id, 
					  transaction_type_name,
					  country_id, 
					  country_code, 
					  country_name, 
					  region_id, 
					  region_name, 
					  income_group_id, 
					  income_group_name, 
					  income_group_acronym,
					  foreign_assistance_objective, 
					  foreign_assistance_objective_1,
					  funding_account_id, 
					  funding_account_name, 
					  funding_agency_id, 
					  funding_agency_name, 
					  funding_agency_acronym,
					  managing_agency_id, 
					  managing_agency_name, 
					  managing_agency_acronym,
					  activity_id,
				      activity_name,
					  activity_description,
					  fiscal_year,
					  transaction_date,
					  current_dollar_amount,
					  constant_dollar_amount,
					  activity_budget_amount,
					  activity_start_date,
					  activity_end_date
					  )
VALUES (99999995,									   -- id
		99999995,                                    -- us_sector_id
		'us_sector_id_99999995',                     -- us_sector_name
		99999995,                                    -- us_category_id
		'us_category_name_99999995',                 -- us_category_name
		99999995,                                    -- aid_type_group_id
		'aid_type_group_name_99999995',              -- aid_type_group_name
		99999995,                                    -- aid_type_id
		'aid_type_name_99999995' ,                   -- aid_type_name										
		99999995,								       -- international_category_id,
		'international_category_99999995',           -- international_category_name
		99999995,                                    -- international_sector_code
		'international_sector_99999995',             -- international_sector_name
		99999995,                                    -- international_purpose_code
		'international_purpose_99999995',            -- international_purpose_name
		99999995,                                    -- transaction_type_id
		'transaction_type_name_99999995',            -- transaction_type_name
		99999995,                                    -- country_id
		'code_99999995',                              -- country_code
		'country_99999995',                           -- country_name
		99999995,                                    -- region_id
		'region_99999995',                           -- region_name
		99999995,                                    -- income_group_id
		'income_group_name_99999995',                -- income_group_name
		'income_group_acronym_99999995',             -- income_group_acronym
		99999995,                                    -- foreign_assistance_objective
		'foreign_assistance_objective_99999995',     -- foreign_assistance_objective_1
		'99x995',                                  -- funding_account_id
		'funding_account_name_99999995',             -- funding_account_name
		99999995,                                    -- funding_agency_id
		'funding_agency_name_99999995',              -- funding_agency_name
		'funding_agency_acronym_99999995',           -- funding_agency_acronym
		99999995,                                    -- managing_agency_id
		'managing_agency_name_99999995',             -- managing_agency_name
		'managing_agency_acronym_99999995',          -- managing_agency_acronym
		99999995,			                           -- activity_id,
		'activity_name_99999995',		               -- activity_name,
		'activity_description_99999995',			   -- activity_description,
		'2020-01-01',			                           -- fiscal_year,
		'2020-12-12 20:42:43.443',			       -- transaction_date,
		9000000.00,			                       -- current_dollar_amount,
		9000000.00,                                -- constant_dollar_amount,
		9000000.00,                                -- activity_budget_amount,
		'2020-12-12 20:42:43.443',                  -- activity_start_date,
		'2020-12-12 20:42:43.443'                  -- activity_end_date
);

--EXEC sp_help raw_data;
--ENABLE TRIGGER ALL ON DATABASE;
--DISABLE TRIGGER ALL ON DATABASE;
--SELECT * FROM raw_data;
--DELETE FROM raw_data;


-- ***************************************** UDT Table Type ************************************************************
-- Let's create a UDT (table type) based on raw_data table. We'll use it for temp Inserted tables in triggers and procedures.

DROP TYPE IF EXISTS TpRawDataInsert

CREATE TYPE TpRawDataInsert AS TABLE
	(id BIGINT,
	country_id BIGINT,
	country_code NVARCHAR(MAX),
	country_name NVARCHAR(MAX),
	region_id BIGINT, 
	region_name NVARCHAR(MAX), 
	income_group_id BIGINT, 
	income_group_name NVARCHAR(MAX), 
	income_group_acronym NVARCHAR(MAX), 
	managing_agency_id BIGINT, 
	managing_agency_acronym NVARCHAR(MAX), 
	managing_agency_name NVARCHAR(MAX), 
	managing_sub_agency_or_bureau BIGINT, 
	managing_sub_agency_or_bureau_1 NVARCHAR(MAX),
	managing_sub_agency_or_bureau_2 NVARCHAR(MAX), 
	implementing_partner_category BIGINT, 
	implementing_partner_category_1 NVARCHAR(MAX), 
	implementing_partner_sub BIGINT, 
	implementing_partner_sub_1 NVARCHAR(MAX), 
	implementing_partner_id BIGINT, 
	implementing_partner_name NVARCHAR(MAX), 
	international_category_id BIGINT, 
	international_category_name NVARCHAR(MAX), 
	international_sector_code BIGINT, 
	international_sector_name NVARCHAR(MAX), 
	international_purpose_code BIGINT, 
	international_purpose_name NVARCHAR(MAX), 
	us_category_id BIGINT, 
	us_category_name NVARCHAR(MAX), 
	us_sector_id BIGINT, 
	us_sector_name NVARCHAR(MAX), 
	funding_account_id NVARCHAR(MAX), 
	funding_account_name NVARCHAR(MAX), 
	funding_agency_id BIGINT, 
	funding_agency_name NVARCHAR(MAX), 
	funding_agency_acronym NVARCHAR(MAX), 
	foreign_assistance_objective BIGINT, 
	foreign_assistance_objective_1 NVARCHAR(MAX), 
	aid_type_group_id BIGINT, 
	aid_type_group_name NVARCHAR(MAX), 
	activity_id BIGINT, 
	submission_id BIGINT, 
	activity_name NVARCHAR(MAX), 
	activity_description NVARCHAR(MAX), 
	activity_project_number NVARCHAR(MAX), 
	transaction_type_id BIGINT, 
	transaction_type_name NVARCHAR(MAX), 
	fiscal_year DATETIME2, 
	transaction_date DATETIME2, 
	current_dollar_amount FLOAT, 
	constant_dollar_amount FLOAT, 
	aid_type_id BIGINT, 
	aid_type_name NVARCHAR(MAX), 
	activity_budget_amount NVARCHAR(MAX), 
	submission_activity_id BIGINT, 
	activity_start_date DATETIME2, 
	activity_end_date DATETIME2
); 



-- *************************************  Inserting new data to dimensions and fact table ***********************************************

-- Our goal is to create 8 procedures, each for one dimension. 
-- Each procedure inserts new data to the relevant catalogue and the fact table.
-- So procedure prCatalogueInsertion_1 inserts new data to the 1st dimension (us_sector - us_category) and to the fact table.
-- Procedure prCatalogueInsertion_2 inserts new data to the 2st dimension (aid_type - aid_type_group) and to the fact table. And so on.
-- A trigger total_raw_insert executes all the the procedures.

-- Just to revise current dimensions:
-- 1 dim:    us_sector --> us_category
-- 2 dim:    aid_type --> aid_type_group
-- 3 dim:    international_purpose --> international_sector --> international_category
-- 4 dim:    transaction_type
-- 5 dim:    country --> income_group, country --> region
-- 6 dim:    foreign_assistance_objective
-- 7 dim:    funding_account --> funding_agency
-- 8 dim:    managing_agency


-- Let's check all enanbled and disabled triggers in the DB
SELECT *
FROM sys.triggers st
INNER JOIN sys.tables sta
ON st.parent_id = sta.object_id
WHERE st.name NOT LIKE '%Log%'; -- in order to hide triggers for Logging DUI for now.


-- Let's check all existing procedures in the DB
SELECT *
FROM sys.procedures;


-- Let's create a trigger, that executes all procedures
DROP TRIGGER IF EXISTS total_raw_insert;

GO
CREATE OR ALTER TRIGGER total_raw_insert
ON raw_data
AFTER INSERT
AS
BEGIN
	
	DECLARE @InsertedData TpRawDataInsert;

	INSERT INTO @InsertedData
	SELECT *
	FROM inserted;

	PRINT('Our trigger has fired! Now let''s execute the related stored procedures!');

	EXEC prCatalogueInsertion_1 @InsertedData ;
	EXEC prCatalogueInsertion_2 @InsertedData ;
	EXEC prCatalogueInsertion_3 @InsertedData ;
	EXEC prCatalogueInsertion_4 @InsertedData ;
	EXEC prCatalogueInsertion_5 @InsertedData ;
	EXEC prCatalogueInsertion_6 @InsertedData ;
	EXEC prCatalogueInsertion_7 @InsertedData ;
	EXEC prCatalogueInsertion_8 @InsertedData ;
	EXEC prActions_0 @InsertedData;

END;



-- (1) Procedure prCatalogueInsertion_1 inserts into dimension 1 (us_sector / us_category)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_1
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_1;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_1');

		INSERT INTO us_category (us_category_id, us_category_name)
		SELECT DISTINCT rd.us_category_id, rd.us_category_name
		FROM @InsertedData rd 
		LEFT JOIN us_category uc
		ON rd.us_category_id = uc.us_category_id
		WHERE uc.us_category_id IS NULL;

		INSERT INTO us_sector ( us_sector_id,  us_sector_name, us_category_id)
		SELECT DISTINCT rd.us_sector_id, rd.us_sector_name, rd.us_category_id
		FROM @InsertedData rd 
		LEFT JOIN us_sector us
		ON rd.us_sector_id = us.us_sector_id
		WHERE us.us_sector_id IS NULL;

		COMMIT TRANSACTION trCatalogueInsertion_1;
		PRINT('Procedure prCatalogueInsertion_1 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_1!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; -- In fact, INSERT was ralled back (the entire chain on commands).
	END CATCH;

END;
GO


-- (2) Procedure prCatalogueInsertion_2 inserts into dimension 2 (aid_type / aid_type_group)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_2
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_2;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_2');

		-- 
		INSERT INTO aid_type_group (aid_type_group_id, aid_type_group_name)
		SELECT DISTINCT rd.aid_type_group_id, rd.aid_type_group_name
		FROM @InsertedData rd 
		--FROM raw_data rd
		LEFT JOIN aid_type_group atg
		ON rd.aid_type_group_id = atg.aid_type_group_id
		WHERE atg.aid_type_group_id IS NULL;


		INSERT INTO aid_type (aid_type_id, aid_type_name, aid_type_group_id)
		SELECT DISTINCT rd.aid_type_id, rd.aid_type_name, rd.aid_type_group_id
		FROM @InsertedData rd 
		--FROM raw_data rd
		LEFT JOIN aid_type [at]
		ON rd.aid_type_id = [at].aid_type_id
		WHERE [at].aid_type_id IS NULL;


		COMMIT TRANSACTION trCatalogueInsertion_2;
		PRINT('Procedure prCatalogueInsertion_2 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_2!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;
GO




-- (3) Procedure prCatalogueInsertion_3 inserts into dimension 3 (international_category/ international_sector/ international_purpose)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_3
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_3;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_3');

		INSERT INTO international_category (international_category_id, international_category_name)
		SELECT DISTINCT rd.international_category_id, rd.international_category_name 
		FROM @InsertedData rd 
		LEFT JOIN international_category ic
		ON rd.international_category_id = ic.international_category_id
		WHERE ic.international_category_id IS NULL;

		INSERT INTO international_sector (international_sector_id, international_sector_name, international_category_id)
		SELECT DISTINCT rd.international_sector_code, rd.international_sector_name, rd.international_category_id
		FROM raw_data rd 
		LEFT JOIN international_sector [is]
		ON rd.international_sector_code = [is].international_sector_id
		WHERE [is].international_sector_id IS NULL;

		INSERT INTO international_purpose (international_purpose_id, international_purpose_name, international_sector_id)
		SELECT DISTINCT rd.international_purpose_code, rd.international_purpose_name, rd.international_sector_code
		FROM raw_data rd 
		LEFT JOIN international_purpose [ip]
		ON rd.international_purpose_code = [ip].international_purpose_id
		WHERE [ip].international_purpose_id IS NULL;

		COMMIT TRANSACTION trCatalogueInsertion_3;
		PRINT('Procedure prCatalogueInsertion_3 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_3!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;


GO



-- (4) Procedure prCatalogueInsertion_3 inserts into dimension 3  (transaction_type)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_4
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_4;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_4');

		-- 
		INSERT INTO transaction_type (transaction_type_id, transaction_type_name)
		SELECT DISTINCT rd.transaction_type_id, rd.transaction_type_name
		FROM @InsertedData rd 
		--FROM raw_data rd
		LEFT JOIN transaction_type tt
		ON rd.transaction_type_id = tt.transaction_type_id
		WHERE tt.transaction_type_id IS NULL;


		COMMIT TRANSACTION trCatalogueInsertion_4;
		PRINT('Procedure prCatalogueInsertion_4 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_4!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;
GO



-- (5) Procedure prCatalogueInsertion_5 inserts into dimension 5 (country / income_group / region)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_5
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_5;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_5');

		INSERT INTO income_group (income_group_id, income_group_name, income_group_acronym)
		SELECT DISTINCT rd.income_group_id, rd.income_group_name, rd.income_group_acronym
		FROM @InsertedData rd 
		LEFT JOIN income_group ig
		ON rd.income_group_id = ig.income_group_id
		WHERE ig.income_group_id IS NULL;


		INSERT INTO region (region_id, region_name)
		SELECT DISTINCT rd.region_id, rd.region_name
		FROM @InsertedData rd 
		LEFT JOIN region r
		ON rd.region_id = r.region_id
		WHERE r.region_id IS NULL;


		INSERT INTO country (country_id, country_code, country_name, region_id, income_group_id)
		SELECT DISTINCT rd.country_id, rd.country_code, rd.country_name, rd.region_id, rd.income_group_id
		FROM @InsertedData rd 
		LEFT JOIN country c
		ON rd.country_id = c.country_id
		WHERE c.country_id IS NULL;

		COMMIT TRANSACTION trCatalogueInsertion_5;
		PRINT('Procedure prCatalogueInsertion_5 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_5!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;
GO



-- (6) Procedure prCatalogueInsertion_6 inserts into dimension 6 (foreign_assistance_objective)      
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_6
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_6;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_6');

		-- 
		INSERT INTO foreign_assistance_objective (foreign_assistance_objective_id, foreign_assistance_objective_name)
		SELECT DISTINCT rd.foreign_assistance_objective, rd.foreign_assistance_objective_1
		FROM @InsertedData rd 
		LEFT JOIN foreign_assistance_objective fao
		ON rd.foreign_assistance_objective = fao.foreign_assistance_objective_id
		WHERE fao.foreign_assistance_objective_id IS NULL;


		COMMIT TRANSACTION trCatalogueInsertion_6;
		PRINT('Procedure prCatalogueInsertion_6 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_6!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;


GO
SELECT * FROM raw_data;
SELECT * FROM foreign_assistance_objective;

DELETE FROM raw_data
WHERE id IS NULL;

DELETE FROM foreign_assistance_objective
WHERE foreign_assistance_objective_id = 44444;



-- (7) Procedure prCatalogueInsertion_7 inserts into dimension 7  (funding_account / funding_agency)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_7
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_7;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_7');

		
		INSERT INTO funding_agency (funding_agency_id, funding_agency_name, funding_agency_acronym)
		SELECT DISTINCT rd.funding_agency_id, rd.funding_agency_name, rd.funding_agency_acronym
		FROM @InsertedData rd 
		LEFT JOIN funding_agency fa
		ON rd.funding_agency_id = fa.funding_agency_id
		WHERE fa.funding_agency_id IS NULL;

		--EXEC sp_help funding_account

		INSERT INTO funding_account (funding_account_id, funding_account_name, funding_agency_id)
		SELECT DISTINCT rd.funding_account_id, rd.funding_account_name, rd.funding_agency_id
		FROM @InsertedData rd 
		LEFT JOIN funding_account fac
		ON rd.funding_account_id = fac.funding_account_id
		WHERE fac.funding_account_id IS NULL;

		COMMIT TRANSACTION trCatalogueInsertion_7;
		PRINT('Procedure prCatalogueInsertion_7 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_7!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;



-- (8) Procedure prCatalogueInsertion_8 inserts into dimension 8 (managing_agency)
GO
CREATE OR ALTER PROCEDURE prCatalogueInsertion_8
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trCatalogueInsertion_8;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prCatalogueInsertion_8');

		-- 
		INSERT INTO managing_agency (managing_agency_id, managing_agency_name, managing_agency_acronym)
		SELECT DISTINCT rd.managing_agency_id, rd.managing_agency_name, rd.managing_agency_acronym
		FROM @InsertedData rd 
		-- FROM raw_data rd
		LEFT JOIN managing_agency ma
		ON rd.managing_agency_id = ma.managing_agency_id
		WHERE ma.managing_agency_id IS NULL;

		COMMIT TRANSACTION trCatalogueInsertion_8;
		PRINT('Procedure prCatalogueInsertion_8 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prCatalogueInsertion_8!!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 

	END CATCH;

END;
GO



-- (0) Procedure prActions_0 inserts into fact table actions

-- Now that we have upgraded all dimensions, let's update fact table.
GO
CREATE OR ALTER PROCEDURE prActions_0
				 @InsertedData TpRawDataInsert READONLY
AS
BEGIN

	BEGIN TRANSACTION trActions_0;

	BEGIN TRY
		
		PRINT('Let''s start insertion through procedure prActions_0');

		INSERT INTO actions (actions_id, 
							country_id, 
							managing_agency_id, 
							us_sector_id, 
							--funding_account_id1, 
							international_purpose_id, 
							foreign_assistance_objective_id, 
							aid_type_id, 
							activity_id, 
							activity_name,
							activity_description, 
							transaction_type_id, 
							fiscal_year, 
							transaction_date, 
							current_dollar_amount, 
							constant_dollar_amount, 
							activity_budget_amount, 
							activity_start_date, 
							activity_end_date)
		SELECT DISTINCT 
							rd.id,
							rd.country_id,
							rd.managing_agency_id,
							rd.us_sector_id,
							--rd.funding_account_id,
							international_purpose_code,
							rd.foreign_assistance_objective,
							rd.aid_type_id,
							rd.activity_id,
							rd.activity_name,
							rd.activity_description,
							rd.transaction_type_id,
							rd.fiscal_year,
							rd.transaction_date,
							rd.current_dollar_amount,
							rd.constant_dollar_amount,
							rd.activity_budget_amount,
							rd.activity_start_date,
							rd.activity_end_date
		FROM @InsertedData rd 
		LEFT JOIN actions a
		ON rd.id = a.actions_id
		WHERE a.actions_id IS NULL;

-- For now we have upgraded catalogues and actions table (except funding_account).
-- So let's update actions' column funding_account manually.
		UPDATE actions
		SET funding_account_id1 = fac.funding_account_id1
		FROM raw_data rd 
		LEFT JOIN actions a
		ON rd.id = a.actions_id
		LEFT JOIN funding_account fac
		ON rd.funding_account_id = fac.funding_account_id

		COMMIT TRANSACTION trActions_0;
		PRINT('Procedure prActions_0 is done.');

	END TRY
	BEGIN CATCH
		PRINT('Error has happened in procedure prActions_0!');
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION; 
	END CATCH;

END;
GO




