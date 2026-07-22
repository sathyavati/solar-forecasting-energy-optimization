CREATE DATABASE solar;
USE solar;
CREATE TABLE plant1_generation (
    date_time    DATETIME,
    plant_id     INT,
    source_key   VARCHAR(20),   -- inverter ID
    dc_power     DOUBLE,
    ac_power     DOUBLE,
    daily_yield  DOUBLE,
    total_yield  DOUBLE,
    INDEX idx_dt (date_time),
    INDEX idx_src (source_key)
);
CREATE TABLE plant2_generation LIKE plant1_generation;
CREATE TABLE plant1_weather (
    date_time            DATETIME,
    plant_id             INT,
    source_key           VARCHAR(20),  -- weather sensor ID
    ambient_temperature  DOUBLE,
    module_temperature   DOUBLE,
    irradiation          DOUBLE,
    INDEX idx_dt (date_time)
);
CREATE TABLE plant2_weather LIKE plant1_weather;

