-- Single line comments in SQL start with two dashes. 

/* 
Multiple line comments are enclosed like this  
*/

-- Task 1: Get to know our data
-- Show all of the tables. Selecting "SHOW TABLES;" with your cursor and running it, will run only that part.
SHOW TABLES;
-- We should make some notes here


 -- location table
SELECT
   *
FROM
location
WHERE province_name = 'Bello Azibo';

-- Add some notes

-- Task 2: Dive into the water sources
SELECT 
 *
 FROM 
 water_source
WHERE number_of_people_served > 3900;
-- Task 3: Unpack the visits to water sources
SELECT
*
FROM 
visits
LIMIT 10;
-- Task 4: Assess the quality of water sources
SELECT 
*
FROM 
water_quality
LIMIT 10;

-- Task 5: Investigate any pollution issues
SELECT 
*
FROM 
well_pollution
LIMIT 10;


SELECT 
*
FROM employee
WHERE 
(phone_number LIKE '%86%' OR phone_number LIKE  '%11%')
AND (employee_name LIKE 'A%' OR employee_name LIKE 'M%')
AND position = 'Field Surveyor';

SELECT COUNT(*)
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);

SELECT COUNT(*)
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;