USE solar;
-- Q1. Daily energy produced per plant (MWh)
-- Energy = sum of 15-min power readings x 0.25h / 1000
SELECT DATE(date_time)                        AS day,
       ROUND(SUM(plant_ac_kw) * 0.25 / 1000, 1) AS energy_mwh
FROM plant1_clean
GROUP BY DATE(date_time)
ORDER BY day;

-- Q2. Both plants side by side, daily 
SELECT DATE(p1.date_time)                          AS day,
       ROUND(SUM(p1.plant_ac_kw) * 0.25 / 1000, 1) AS plant1_mwh,
       ROUND(SUM(p2.plant_ac_kw) * 0.25 / 1000, 1) AS plant2_mwh
FROM plant1_clean p1
JOIN plant2_clean p2 ON p1.date_time = p2.date_time
GROUP BY DATE(p1.date_time)
ORDER BY day;

-- Q3. Rank inverters by average daytime output 
--     Uses the raw per-inverter table on purpose
SELECT source_key,
       ROUND(AVG(ac_power), 1)                      AS avg_ac_kw,
       RANK() OVER (ORDER BY AVG(ac_power) ASC)     AS rank_worst_first,
       ROUND(100 * AVG(ac_power)
             / MAX(AVG(ac_power)) OVER (), 1)       AS pct_of_best
FROM plant1_generation
WHERE ac_power > 0
GROUP BY source_key
ORDER BY rank_worst_first;

-- Q4. Day-over-day change in plant output 
WITH daily AS (
    SELECT DATE(date_time) AS day,
           SUM(plant_ac_kw) * 0.25 / 1000 AS mwh
    FROM plant1_clean
    GROUP BY DATE(date_time)
)
SELECT day,
       ROUND(mwh, 1)                                 AS mwh,
       ROUND(mwh - LAG(mwh) OVER (ORDER BY day), 1)  AS change_vs_prev_day,
       ROUND(100 * (mwh - LAG(mwh) OVER (ORDER BY day))
             / LAG(mwh) OVER (ORDER BY day), 1)      AS pct_change
FROM daily
ORDER BY day;

-- Q5. Fault detection: full sun but (near-)zero inverter output
SELECT g.date_time,
       g.source_key,
       ROUND(w.irradiation, 2) AS irradiation,
       ROUND(g.ac_power, 1)    AS ac_kw
FROM plant1_generation g
JOIN plant1_weather   w ON g.date_time = w.date_time
WHERE w.irradiation > 0.6
  AND g.ac_power < 100
ORDER BY w.irradiation DESC;
 
-- Summary of fault events
SELECT COUNT(*)                     AS suspect_readings,
       COUNT(DISTINCT g.source_key) AS inverters_affected,
       MIN(g.date_time)             AS first_event,
       MAX(g.date_time)             AS last_event
FROM plant1_generation g
JOIN plant1_weather   w ON g.date_time = w.date_time
WHERE w.irradiation > 0.6
  AND g.ac_power < 100;
 
 
-- Q6. Missing-data audit
-- 6a. Timestamps where fewer than 22 inverters reported
SELECT 
    date_time, inverters_reporting
FROM
    plant1_clean
WHERE
    inverters_reporting < 22
ORDER BY inverters_reporting ASC , date_time;

-- 6b. Completely missing 15-min slots per day
SELECT DATE(date_time)           AS day,
       96 - COUNT(*)             AS missing_slots
FROM plant1_clean
GROUP BY DATE(date_time)
HAVING missing_slots > 0
ORDER BY missing_slots DESC;

-- Q6c. Inverter dropout audit (Plant 2): timestamps reported vs missing per inverter.
SELECT source_key, COUNT(DISTINCT date_time) AS ts_reported,
       3259 - COUNT(DISTINCT date_time)      AS ts_missing
FROM plant2_generation
GROUP BY source_key
ORDER BY ts_reported ASC;

-- Q7. Hourly generation profile with peak/daylight/night buckets
SELECT HOUR(date_time)                    AS hr,
       ROUND(AVG(plant_ac_kw) / 1000, 2)  AS avg_mw,
       CASE
         WHEN HOUR(date_time) BETWEEN 10 AND 15 THEN 'peak'
         WHEN HOUR(date_time) BETWEEN 6  AND 18 THEN 'daylight'
         ELSE 'night'
       END AS period
FROM plant1_clean
GROUP BY hr, period
ORDER BY hr;