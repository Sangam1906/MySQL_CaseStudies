/* QA. Data Exploration and Cleansing
Q!. Update the fresh_segments.intrest_metrics table by modifying
the month_year column to be a date data type with the start of
 the month*/
-- Step 1: Add a new column to store the modified date values
ALTER TABLE fresh_segments.interest_metrics
ADD COLUMN new_month_year DATE;

-- Step 2: Update the new column with the start of the month values
UPDATE fresh_segments.interest_metrics
SET new_month_year = DATE_FORMAT(STR_TO_DATE(month_year, '%m-%Y'), '%Y-%m-01');

-- Step 3: Drop the old month_year column
ALTER TABLE fresh_segments.interest_metrics
DROP COLUMN month_year;

-- Step 4: Optionally, rename the new column to month_year
ALTER TABLE fresh_segments.interest_metrics
CHANGE COLUMN new_month_year month_year DATE;

SELECT*
FROM interest_metrics;

/*Q2. What is count of records in the fresh_segments.interest_metrics
for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
*/
SELECT month_year, COUNT(*) AS record_count
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY 
CASE WHEN month_year IS NULL THEN 0 ELSE 1 END,  -- Null values appear first
STR_TO_DATE(month_year, '%m-%Y');              -- Chronological order

/*Q3. What do you think we should do with these 
null values in the fresh_segments.interest_metrics*/
SELECT month_year, COUNT(*) AS record_count
FROM interest_metrics
WHERE month_year IS NOT NULL
GROUP BY month_year
ORDER BY month_year;

/*Q4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_
segments.interest_map table? What about the other way around?*/
SELECT COUNT(DISTINCT im.interest_id) AS count_interest_metrics_not_in_map
FROM interest_metrics im
LEFT JOIN interest_map map ON im.interest_id = map.id
WHERE map.id IS NULL;

SELECT COUNT(DISTINCT map.id) AS count_interest_map_not_in_metrics
FROM interest_map map
LEFT JOIN interest_metrics im ON map.id = im.interest_id
WHERE im.interest_id IS NULL;

/*Q5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
*/
SELECT id, interest_name, COUNT(*) AS record_count
FROM interest_map im
JOIN interest_metrics ime ON im.id = ime.interest_id
GROUP BY id, interest_name
ORDER BY record_count DESC;

/*Q6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
*/
SELECT
  im.*,
  map.interest_name AS mapped_interest_name,
  map.interest_summary AS mapped_interest_summary,
  map.created_at AS mapped_created_at,
  map.last_modified AS mapped_last_modified
FROM interest_metrics AS im
LEFT JOIN interest_map AS map ON im.interest_id = map.id
WHERE im.interest_id = 21246;

/*Q7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
*/
SELECT
    im.*,
    im.month_year AS interest_metrics_month_year,
    map.created_at AS interest_map_created_at
FROM
    interest_metrics AS im
LEFT JOIN
    interest_map AS map
ON
    im.interest_id = map.id
WHERE
    im.month_year < map.created_at
ORDER BY
    im.interest_id, im.month_year;

/*B. Interest Analysis*/
/*Q1. Which interests have been present in all month_year dates in our dataset?*/
SELECT DISTINCT interest_id
FROM interest_metrics 
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) = (SELECT COUNT(DISTINCT month_year) FROM interest_metrics);

/*Q2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
*/
WITH MonthlyInterestCounts AS (
  SELECT interest_id, COUNT(DISTINCT month_year) AS month_count
  FROM interest_metrics
  GROUP BY interest_id
),
InterestCumulativePercentage AS (
  SELECT
      month_count,
      COUNT(interest_id) AS interest_count,
      SUM(COUNT(interest_id)) OVER (ORDER BY month_count DESC) AS total_interest_count
  FROM MonthlyInterestCounts
  GROUP BY month_count
)
SELECT
  month_count,
  total_interest_count,
  ROUND(total_interest_count * 100.0 / (SELECT SUM(interest_count) FROM InterestCumulativePercentage), 2) AS cumulative_percent
FROM InterestCumulativePercentage
WHERE ROUND(total_interest_count * 100.0 / (SELECT SUM(interest_count) FROM InterestCumulativePercentage), 2) > 90;


