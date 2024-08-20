USE md_water_services;

SELECT * FROM visits;
SELECT * FROM water_source;
SELECT * FROM water_source;

-- Query data from different tables
SELECT 
   l.province_name,
   l.town_name,
   l.location_type,
   v.time_in_queue,
   ws.type_of_water_source,
   ws.number_of_people_served,
   wp.results
FROM visits v
JOIN location l
ON l.location_id = v.location_id
JOIN water_source ws
ON ws.source_id = v.source_id
LEFT JOIN well_pollution wp
ON wp.source_id = v.source_id
WHERE v.visit_count= 1;

-- CREATE VIEW OF THE TABLE ABOVE TO EASILY USE IT FOR ANALYSIS
CREATE VIEW combined_analysis_table AS
SELECT 
   l.province_name,
   l.town_name,
   l.location_type,
   v.time_in_queue,
   ws.type_of_water_source,
   ws.number_of_people_served,
   wp.results
FROM visits v
JOIN location l
ON l.location_id = v.location_id
JOIN water_source ws
ON ws.source_id = v.source_id
LEFT JOIN well_pollution wp
ON wp.source_id = v.source_id
WHERE v.visit_count= 1;

-- Data into provinces, towns and source types
-- START WITH PROVINCES

-- CTE THAT calcualtes SUM of all people surveyed group by province
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name -- To get provincional percentages
ORDER BY
ct.province_name;

   -- Sokoto has the largest population of people drinking river water
   -- Majortiy of water from Amanzi comes from Tap
   -- Most of broken home taps are in Amanzi
   
   -- GO TO TOWNS
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river' -- percentage of peope using each source type using the case statements
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.province_name DESC;


-- Create a temporary table out of the query above
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river' -- percentage of peope using each source type using the case statements
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

-- Town with the highest ratio of people who have taps but no running water
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS Pct_broken_taps
FROM
town_aggregated_water_access
ORDER BY Pct_broken_taps desc;


-- CREATE A TABLE AS FINAL TASK
-- Fix, upgrade and repair water sources
-- addresses, type of water source, what should be done to improve, and update they can provide

-- CREATE THE PROJECT PROGRESS TABLE
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY, -- unique id for sources
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50), -- street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- what should be done at the place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE, -- day source has been upgraded
Comments TEXT
);

-- by default all projects are in backlog which is like a to do list
-- check() ensures only 3 options to be accepted


--  Project_progress_query
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE WHEN water_source.type_of_water_source = 'River' THEN 'Drill Well'
     WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter and RO filter'
     WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
     WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN CONCAT('Install ',  FLOOR(visits.time_in_queue), " taps nearby")
     WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagonose local infrastructure'
     ELSE NULL
     END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1 AND 
((water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue > 30) OR
(water_source.type_of_water_source = 'well' AND well_pollution.results != 'Clean') OR
water_source.type_of_water_source IN ('river', 'tap_in_home_broken'));

-- Last task would be inserting the results of my new query into the newly created progress table
SELECT 
COUNT('Install UV filter and RO filter') 
FROM
water_source;

SELECT 
COUNT('Install RO filter') 
FROM
water_source;