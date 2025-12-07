

-- ************************************************** CHECK-UPs for POWER BI DASHBOARD ***************************************************

Use Usaid;
GO



-- ************************************************** CHECK-UP for Dashboard's Heatmap ("Worlds_Heatmap" report page) *********************

WITH cte1 AS (
SELECT COALESCE(income_group_name, 'no_income_group') income_group_name, 
		region_name, 
		sum(constant_dollar_amount) dollar_amount
FROM country c
LEFT JOIN region r
ON c.region_id = r.region_id
LEFT JOIN income_group ig
ON c.income_group_id = ig.income_group_id
LEFT JOIN actions a
ON c.country_id = a.country_id
WHERE transaction_type_id = 2 
GROUP BY income_group_name, region_name
),
cte2 AS
(SELECT region_name, [High Income Country], [Upper Middle Income Country], [Lower Middle Income Country], [Low Income Country], [no_income_group]
FROM cte1
PIVOT( 
	sum(dollar_amount)
	FOR [income_group_name]
	IN ([High Income Country], [Upper Middle Income Country], [Lower Middle Income Country], [Low Income Country], [no_income_group])
) as pvt)
SELECT region_name, 
		dbo.fnFormatN([High Income Country]) [High Income Country], 
		dbo.fnFormatN([Upper Middle Income Country]) [Upper Middle Income Country], 
		dbo.fnFormatN([Lower Middle Income Country]) [Lower Middle Income Country],
		dbo.fnFormatN([Low Income Country]) [Low Income Country],
		dbo.fnFormatN([no_income_group]) [No Income Group]
FROM cte2
;
GO



-- ************************************************** CHECK-UP for Dashboard's Waterfall ("Country_Waterfall" report page) *********************

DECLARE @country_name NVARCHAR(100) = 'Syria';

SELECT dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM actions
WHERE country_id = (SELECT country_id FROM country c WHERE c.country_name = @country_name)
	AND transaction_type_id = 2;

WITH cte1 AS (
SELECT YEAR(fiscal_year) fiscal_year, 
		sum(constant_dollar_amount) dollar_amount
FROM actions
WHERE country_id = (SELECT country_id FROM country c WHERE c.country_name = @country_name)
	AND transaction_type_id = 2
GROUP BY YEAR(fiscal_year)
--ORDER BY YEAR(fiscal_year)
)
SELECT fiscal_year, 
		dbo.fnFormatN(dollar_amount) dollar_amount, 
		dbo.fnFormatN(LAG(dollar_amount, 1) OVER (ORDER BY fiscal_year ASC)) previous_dollar_amount, 
		100*(dollar_amount / (LAG(dollar_amount, 1) OVER (ORDER BY fiscal_year ASC)) - 1) yoy_percent
FROM cte1
ORDER BY YEAR(fiscal_year) ASC;



-- ***************************************** CHECK-UP for Dashboard's Country Card ("Country_General" report page) *********************************

-- ****** Total Constant Dollar Amount

-- a) through Actions table
SELECT dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM actions a
LEFT JOIN country c
ON a.country_id = c.country_id
LEFT JOIN region r
ON c.region_id = r.region_id
WHERE transaction_type_id = 2;

-- b) through Indexed View
SELECT dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM [Usaid].[dbo].[view_actions_dir_1_5_6]                                             



-- ***** Total Constant Dollar Amount by regions

-- a) through Actions table
SELECT region_name, 
		dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM actions a
LEFT JOIN country c
ON a.country_id = c.country_id
LEFT JOIN region r
ON c.region_id = r.region_id
WHERE transaction_type_id = 2
GROUP BY region_name;

-- b) through Indexed View
SELECT region_name, 
	dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM view_actions_dir_1_5_6                                                   
GROUP BY region_name;



-- ***** Total Constant Dollar Amount for the chosen region (entire time period)
DECLARE @region NVARCHAR(100) = 'Middle East and North Africa';

WITH cte1 AS (
SELECT region_name, 
	sum(constant_dollar_amount) dollar_amount
FROM actions a
LEFT JOIN country c
ON a.country_id = c.country_id
LEFT JOIN region r
ON c.region_id = r.region_id
WHERE transaction_type_id = 2
GROUP BY region_name)
SELECT dbo.fnFormatN(SUM(dollar_amount)) dollar_amount
FROM cte1;


-- ***** Country Region Share, % (for all countries in the DB)
WITH cte1 AS (
SELECT  DISTINCT 
		c.country_name, 
		r.region_name, 
		SUM(constant_dollar_amount) OVER (PARTITION BY a.country_id) country_sum,
		SUM(constant_dollar_amount) OVER (PARTITION BY r.region_id) region_sum,
		100*(SUM(constant_dollar_amount) OVER (PARTITION BY a.country_id)  / SUM(constant_dollar_amount) OVER (PARTITION BY r.region_id)) share
FROM actions a
INNER JOIN country c
ON a.country_id = c.country_id
INNER JOIN region r
ON c.region_id = r.region_id
WHERE transaction_type_id = 2
)
SELECT  country_name, 
		region_name, 
		dbo.fnFormatN(country_sum) country_sum,
		dbo.fnFormatN(region_sum) region_sum,
		dbo.fnFormatN(share) [share_%]
FROM cte1


-- ***** Number of activities
-- total
SELECT 
	count(*) all_rows,
	count(DISTINCT actions_id) #_actions_id, 
	count(DISTINCT activity_id) #_activity_id, 
	count(DISTINCT activity_name) #_activity_name, 
	count(DISTINCT activity_description) #_activity_description
FROM actions
WHERE transaction_type_id = 2;

-- for the chosen country
DECLARE @country_name NVARCHAR(100) = 'Belarus'
SELECT count(DISTINCT activity_id), sum(constant_dollar_amount) dollar_amount
FROM actions a
WHERE country_id = (SELECT country_id 
					FROM country c 
					WHERE c.country_name = @country_name)
	AND transaction_type_id = 2;



-- ***************************************** CHECK-UP for World's Card ("World_General" report page) *********************************

-- ***** TOP-10 Countries by dollar amount
SELECT TOP (10) country_name, 
		dbo.fnFormatN(SUM(constant_dollar_amount)) dollar_sum
FROM view_actions_dir_1_5_6
WHERE transaction_type_id = 2
GROUP BY country_name
ORDER BY SUM(constant_dollar_amount) DESC;


-- ***** Income Group Viz

-- a) through Actions table
SELECT income_group_name, dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM actions a
LEFT JOIN country c
ON a.country_id = c.country_id
LEFT JOIN income_group ig
ON ig.income_group_id = c.income_group_id_1
WHERE transaction_type_id = 2
GROUP BY income_group_name
ORDER BY dollar_amount DESC;

-- b) through Indexed View
SELECT income_group_name, dbo.fnFormatN(sum(constant_dollar_amount)) dollar_amount
FROM view_actions_dir_1_5_6
GROUP BY income_group_name
ORDER BY dollar_amount DESC;

-- Number of countries
SELECT income_group_name, COUNT(DISTINCT a.country_id)
FROM actions a
LEFT JOIN country c
ON a.country_id = c.country_id
LEFT JOIN income_group ig
ON ig.income_group_id = c.income_group_id_1
WHERE transaction_type_id = 2
GROUP BY income_group_name;

