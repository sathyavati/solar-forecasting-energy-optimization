-- Build cleaned, analysis-ready plant-level tables
-- Fixes handled here:
--   1. Per-inverter rows aggregated to plant level (avoids
--      duplicating the single weather reading 22x on join)
--   2. Partial inverter reporting corrected: AVG(ac_power) * 22
--      instead of SUM, so timestamps where some of the 22
--      inverters failed to report are not biased downward
--   3. NULL power readings excluded
--   (Date-format fix for Plant 1 was already applied at load
--    time via STR_TO_DATE in the loading script.)

USE solar;

CREATE TABLE plant1_clean AS
SELECT g.date_time,
       ROUND(AVG(g.ac_power) * 22, 2)  AS plant_ac_kw,
       ROUND(AVG(g.dc_power) * 22, 2)  AS plant_dc_kw,
       COUNT(DISTINCT g.source_key)    AS inverters_reporting,
       w.ambient_temperature,
       w.module_temperature,
       w.irradiation
FROM plant1_generation g
JOIN plant1_weather   w ON g.date_time = w.date_time
WHERE g.ac_power IS NOT NULL
GROUP BY g.date_time, w.ambient_temperature,
         w.module_temperature, w.irradiation;
 
 CREATE TABLE plant2_clean AS
SELECT g.date_time,
       ROUND(AVG(g.ac_power) * 22, 2)  AS plant_ac_kw,
       ROUND(AVG(g.dc_power) * 22, 2)  AS plant_dc_kw,
       COUNT(DISTINCT g.source_key)    AS inverters_reporting,
       w.ambient_temperature,
       w.module_temperature,
       w.irradiation
FROM plant2_generation g
JOIN plant2_weather   w ON g.date_time = w.date_time
WHERE g.ac_power IS NOT NULL
GROUP BY g.date_time, w.ambient_temperature,
         w.module_temperature, w.irradiation;
         
-- Add indexes for faster querying
ALTER TABLE plant1_clean ADD INDEX idx_dt (date_time);
ALTER TABLE plant2_clean ADD INDEX idx_dt (date_time);    


-- Verification

SELECT 'plant1_clean' AS tbl, COUNT(*) AS n_rows,
       MIN(date_time) AS first_ts, MAX(date_time) AS last_ts
FROM plant1_clean
UNION ALL
SELECT 'plant2_clean', COUNT(*), MIN(date_time), MAX(date_time)
FROM plant2_clean;  

-- How many timestamps needed the partial-reporting correction?
SELECT 'plant1' AS plant,
       SUM(CASE WHEN inverters_reporting < 22 THEN 1 ELSE 0 END) AS partial_ts
FROM plant1_clean
UNION ALL
SELECT 'plant2',
       SUM(CASE WHEN inverters_reporting < 22 THEN 1 ELSE 0 END)
FROM plant2_clean;   
 