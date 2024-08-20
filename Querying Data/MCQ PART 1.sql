-- Answers to the questions in Part 1
SELECT
type_of_water_source
FROM 
water_source;

SELECT 
*
FROM
visits
WHERE 
time_in_queue
> 500;

SELECT 
*
FROM 
water_quality
WHERE 
subjective_quality_score = 10
AND 
visit_count = 2;

SELECT 
*
FROM 
well_pollution
WHERE
results = 'Clean'
AND 
biological > 0.01;


SELECT 
description
FROM 
well_pollution
WHERE description LIKE 'Clean%';

-- Update descriptions that mistakenly mention 
-- 'Clean Bacteria : E. Coli to 'Bacteria: E. coli'
SET SQL_SAFE_UPDATES = 0;

UPDATE
well_pollution
SET
description = 'Bacteria: E. coli'
WHERE 
description = 'Clean Bacteria : E. Coli';

-- Update descriptions that mistakenly mention 
-- 'Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia'

SELECT description
FROM  well_pollution
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE
well_pollution
SET
description = 'Bacteria : Giardia Lamblia'
WHERE 
description = 'Clean Bacteria : Giardia Lamblia';

-- Update the `result` to `Contaminated: Biological` where
-- `biological` is greater than 0.01 plus current results is `Clean`
SELECT * FROM well_pollution;

UPDATE 
well_pollution
SET 
results = 'Contaminated: Biological'
WHERE biological > 0.01 
AND 
results = 'Clean';

CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);

SELECT 
*
FROM 
md_water_services.well_pollution_copy;

UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria : E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria : Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated : Biological'
WHERE
biological > 0.01 AND results = 'Clean';

-- Put a test query here to make sure we fixed the errors
-- Use the query we used to show all of the erroneous rows

SELECT 
* 
FROM 
well_pollution_copy
WHERE description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);


UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';
DROP TABLE
md_water_services.well_pollution_copy;
