USE md_water_services;
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

SELECT * FROM auditor_report;
SELECT * FROM visits;

-- Difference in scores and a pattern
SELECT auditor_report.location_id AS audit_location, 
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id,
water_quality.subjective_quality_score
FROM auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
JOIN water_quality 
ON water_quality.record_id = visits.record_id;

-- renames
SELECT auditor_report.location_id AS location_id, 
visits.record_id,
water_quality.subjective_quality_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
JOIN water_quality 
ON water_quality.record_id = visits.record_id
WHERE visits.visit_count = 1;
 

-- Linking records to employees
WITH Incorrect_records AS (
SELECT auditor_report.location_id AS location_id, 
visits.record_id,
water_quality.subjective_quality_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score,
employee.employee_name AS employee_name
FROM auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
JOIN water_quality 
ON water_quality.record_id = visits.record_id
JOIN employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1)
SELECT employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY employee_name DESC;

-- Gathering some evidence
-- Find employees with an above average of mistakes
-- The CTE above displays records of employees who made a mistake in their records
-- We need to convert it to a view which acts as a virtual table
CREATE VIEW Incorrect_records1 AS (
SELECT 
    auditor_report.location_id AS location_id, 
    visits.record_id,
    water_quality.subjective_quality_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    employee.employee_name AS employee_name,
    auditor_report.statements AS statements
FROM 
    auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
JOIN water_quality 
ON water_quality.record_id = visits.record_id
JOIN employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1
AND auditor_report.true_water_source_score != water_quality.subjective_quality_score);

SELECT * FROM Incorrect_records1;

SELECT
   AVG(number_of_mistakes)  AS avg_error_count_per_empl
FROM error_count;

SELECT 
   employee_name,
   number_of_mistakes
FROM 
    error_count
WHERE number_of_mistakes > avg_error_count_per_empl;

WITH error_count AS (
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records1
GROUP BY employee_name)
SELECT
   employee_name,
   number_of_mistakes
FROM
   error_count
   WHERE number_of_mistakes >
   (SELECT 
   AVG(number_of_mistakes)  AS avg_error_count_per_empl
FROM error_count
);

-- 6 mistakes is the average number of mistakes
-- Create a suspects list CTE that includes employees with an above average number of mistakes 
-- Use the CTE to filter records of the 4 employees
-- Display names and mistakes of these employees

WITH error_count AS (  -- CTE TO calculate number of mistakes each employee makes
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records1 -- VIEW created earlier that joins audit report to the DB
GROUP BY employee_name),
suspect_list AS ( -- CTE TO select employees with above average mistakes
SELECT 
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (
SELECT AVG(number_of_mistakes)
FROM error_count)
)
-- QUery to filter all the records where the corrupt employees gathered data
SELECT
*
FROM
Incorrect_records1
WHERE
employee_name IN (SELECT employee_name FROM suspect_list)
AND location_id IN ('AkRu04508', 'AkRu07310',
'KiRu29639', 'AmAm09607');


-- Details of the 4 employees with mistakes above average i.e: names and number of mistakes
SELECT
   employee_name,
   COUNT(*) AS number_of_mistakes
FROM
   suspect_records
GROUP BY employee_name;


-- To sum up, the 4 employees made more msitakes than their  peers on average
-- They have incriminating statements made against them and only them 

