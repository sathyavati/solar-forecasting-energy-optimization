SET GLOBAL local_infile = 1;
USE solar;
-- Edit the paths
LOAD DATA LOCAL INFILE 'C:/path/to/data/Plant_1_Generation_Data.csv'
INTO TABLE plant1_generation
FIELDS TERMINATED BY ',' IGNORE 1 LINES
(@dt, plant_id, source_key, dc_power, ac_power, daily_yield, total_yield)
SET date_time = STR_TO_DATE(@dt, '%d-%m-%Y %H:%i');

LOAD DATA LOCAL INFILE 'C:/path/to/data/Plant_2_Generation_Data.csv'
INTO TABLE plant2_generation
FIELDS TERMINATED BY ',' IGNORE 1 LINES
(@dt, plant_id, source_key, dc_power, ac_power, daily_yield, total_yield)
SET date_time = STR_TO_DATE(@dt, '%Y-%m-%d %H:%i:%s');
 
LOAD DATA LOCAL INFILE 'C:/path/to/data/Plant_1_Weather_Sensor_Data.csv'
INTO TABLE plant1_weather
FIELDS TERMINATED BY ',' IGNORE 1 LINES
(@dt, plant_id, source_key, ambient_temperature, module_temperature, irradiation)
SET date_time = STR_TO_DATE(@dt, '%Y-%m-%d %H:%i:%s');
 
LOAD DATA LOCAL INFILE 'C:/path/to/data/Plant_2_Weather_Sensor_Data.csv'
INTO TABLE plant2_weather
FIELDS TERMINATED BY ',' IGNORE 1 LINES
(@dt, plant_id, source_key, ambient_temperature, module_temperature, irradiation)
SET date_time = STR_TO_DATE(@dt, '%Y-%m-%d %H:%i:%s');


-- row counts 
SELECT 'p1_gen' AS tbl, COUNT(*) AS n FROM plant1_generation
UNION ALL SELECT 'p2_gen', COUNT(*) FROM plant2_generation
UNION ALL SELECT 'p1_weather', COUNT(*) FROM plant1_weather
UNION ALL SELECT 'p2_weather', COUNT(*) FROM plant2_weather;