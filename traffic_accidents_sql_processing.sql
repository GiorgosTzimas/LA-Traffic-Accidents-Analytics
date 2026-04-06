CREATE TABLE los_angeles_accidents (
  id TEXT PRIMARY KEY,
  severity INT,
  start_time TIMESTAMP WITH TIME ZONE,
  start_lat DOUBLE PRECISION,
  start_lng DOUBLE PRECISION, 
  street TEXT,
  temperature_f FLOAT, 
  humidity_percentage FLOAT, 
  wind_speed_mph FLOAT, 
  precipitation_in FLOAT,
  weather_condition TEXT, 
  amenity BOOLEAN, 
  bump BOOLEAN, 
  crossing BOOLEAN, 
  give_way BOOLEAN,
  junction BOOLEAN, 
  no_exit BOOLEAN, 
  railway BOOLEAN, 
  roundabout BOOLEAN,
  station BOOLEAN, 
  stop BOOLEAN,
  traffic_calming BOOLEAN, 
  traffic_signal BOOLEAN, 
  turning_loop BOOLEAN, 
  sunrise_sunset TEXT,
  civil_twilight TEXT, 
  nautical_twilight TEXT
);


SELECT *
FROM los_angeles_accidents

UPDATE fact_table 
SET city = 'Los Angeles'

-- Create a copy of the original data in order to keep both the raw and the processed
CREATE TABLE los_angeles_accidents_staging AS
SELECT *
FROM los_angeles_accidents

SELECT *
FROM los_angeles_accidents_staging
LIMIT 1000;

-- 1. Remove Duplicates

-- Since we have the unique identifier "id", we can make use of it for removing duplicates
SELECT id, COUNT(id)
FROM los_angeles_accidents_staging
GROUP BY id
HAVING COUNT(id) > 1;
-- No duplicates found based on the id column

-- 2. Standarize the Data

-- street
SELECT street, TRIM(street)
FROM los_angeles_accidents_staging
GROUP BY street;

UPDATE los_angeles_accidents_staging
SET street = TRIM(street);

-- weather_condition
SELECT weather_condition
FROM los_angeles_accidents_staging
GROUP BY weather_condition

SELECT weather_condition, TRIM(weather_condition)
FROM los_angeles_accidents_staging
GROUP BY weather_condition

-- Groupping conditions that have similar impact on accidents
SELECT weather_condition 
FROM los_angeles_accidents_staging
WHERE weather_condition IN ('Clear', 'Fair', 'Fair / Windy')
GROUP BY weather_condition;

-- Group name: Clear
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Clear'
WHERE weather_condition IN ('Clear', 'Fair', 'Fair / Windy');

-- Group name: Cloudy
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Cloudy'
WHERE weather_condition IN ('Cloudy', 'Cloudy / Windy', 'Mostly Cloudy', 'Mostly Cloudy / Windy', 'Overcast', 
                            'Partly Cloudy', 'Partly Cloudy / Windy', 'Scattered Clouds')

-- Group name: Light Rain
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Light Rain'
WHERE weather_condition IN ('Drizzle', 'Light Drizzle', 'Light Rain', 'Light Rain / Windy')

-- Group name: Heavy Rain
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Heavy Rain'
WHERE weather_condition IN ('Heavy Rain', 'Rain', 'Rain / Windy')

-- Group name: Thunderstorm
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Thunderstorm'
WHERE weather_condition IN ('T-Storm', 'Thunder', 'Thunderstorm', 'Light Rain with Thunder', 'Light Thunderstorms and Rain',
                            'Heavy T-Storm')

-- Group name: Fog/Mist
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Fog/Mist'
WHERE weather_condition IN ('Fog', 'Haze', 'Haze / Windy', 'Mist', 'Patches of Fog', 'Shallow Fog', 'Smoke')

-- Group name: Dust
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Dust'
WHERE weather_condition IN ('Blowing Dust', 'Duststorm')

SELECT weather_condition
FROM los_angeles_accidents_staging
GROUP BY weather_condition


-- 3. Null Values

-- Street null values 69. 
SELECT *
FROM los_angeles_accidents_staging
WHERE street IS NULL;

-- Let's replace null with a clearly defined category "Not recorded"
UPDATE los_angeles_accidents_staging
SET street = 'Not recorded'
WHERE street IS NULL;

-- weather_condition has 650 null values.
SELECT weather_condition
FROM los_angeles_accidents_staging
WHERE weather_condition IS NULL 
OR weather_condition = '';

-- Let's do the same as with street category
UPDATE los_angeles_accidents_staging
SET weather_condition = 'Not recorded'
WHERE weather_condition IS NULL
OR weather_condition = '';

-- 1105 null values
SELECT *
FROM los_angeles_accidents_staging
WHERE temperature_f IS NULL;

-- 1180 null values
SELECT *
FROM los_angeles_accidents_staging
WHERE humidity_percentage IS NULL;

-- 23989 null values
SELECT *
FROM los_angeles_accidents_staging
WHERE wind_speed_mph IS NULL;

-- 47471 null values
SELECT *
FROM los_angeles_accidents_staging
WHERE precipitation_in IS NULL;

SELECT 
 100.0 * SUM(CASE WHEN temperature_f IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS temperature_null_percentage,
 100.0 * SUM(CASE WHEN humidity_percentage IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS humidity_null_percentage,
 100.0 * SUM(CASE WHEN wind_speed_mph IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS wind_speed_null_percentage,
 100.0 * SUM(CASE WHEN precipitation_in IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS precipitation_null_percentage
FROM los_angeles_accidents_staging;

SELECT * 
FROM los_angeles_accidents_staging
WHERE temperature_f IS NULL
AND humidity_percentage IS NULL 
AND wind_speed_mph IS NULL
AND precipitation_in IS NULL;

SELECT 
 100.0 * SUM(CASE WHEN temperature_f IS NULL AND
                       humidity_percentage IS NULL AND
				       wind_speed_mph IS NULL AND
				       precipitation_in IS NULL 
					    THEN 1 ELSE 0 END) / COUNT(*) 
FROM los_angeles_accidents_staging
-- Since the percentage of the combined null values of weather conditions are 0.34%, it is safe to remove these rows as they don't provide any important information that we can make use of it

SELECT *
FROM los_angeles_accidents_staging
WHERE temperature_f IS NULL AND
      humidity_percentage IS NULL AND
	  wind_speed_mph IS NULL AND
	  precipitation_in IS NULL

DELETE FROM los_angeles_accidents_staging
WHERE temperature_f IS NULL AND
      humidity_percentage IS NULL AND
	  wind_speed_mph IS NULL AND
	  precipitation_in IS NULL
-- 545 rows were affected

-- 4. Investigate some patterns
SELECT severity,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY severity
ORDER BY severity;

SELECT EXTRACT(DOW FROM start_time) AS day_of_the_week,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY day_of_the_week
ORDER BY day_of_the_week;

SELECT EXTRACT(MONTH FROM start_time) AS month,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY month
ORDER BY month;

SELECT EXTRACT(YEAR FROM start_time) AS year, 
       EXTRACT(MONTH FROM start_time) AS month,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY year, month
ORDER BY num_of_accidents DESC;

SELECT EXTRACT(YEAR FROM start_time) AS year,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY year
ORDER BY num_of_accidents DESC;

SELECT EXTRACT(DOW FROM start_time) AS day_of_the_week,
       severity,
       COUNT(*) AS num_of_accidents
FROM los_angeles_accidents_staging
GROUP BY day_of_the_week, severity
ORDER BY day_of_the_week, severity DESC;

SELECT weather_condition,
       severity,
       COUNT(*) AS accident_count
FROM los_angeles_accidents_staging
GROUP BY weather_condition, severity
ORDER BY weather_condition, accident_count DESC;

-- 4. Handle DateTime
SELECT * FROM los_angeles_accidents_staging
LIMIT 100;

WITH time AS (
SELECT start_time,
       EXTRACT(DAY FROM start_time) AS day,
       EXTRACT(MONTH FROM start_time) AS month,
	   EXTRACT(YEAR FROM start_time) AS year,
	   EXTRACT(DOW FROM start_time) AS day_of_the_week,
	   EXTRACT(DOY FROM start_time) AS day_of_the_year,
	   EXTRACT(WEEK FROM start_time) AS week_number,
	   EXTRACT(QUARTER FROM start_time) AS quarter,
	   (start_time AT TIME ZONE 'America/Los_Angeles')::time AS la_local_time
FROM los_angeles_accidents_staging
)
SELECT severity,
       weather_condition,
	   t.day,
	   t.month,
	   t.year,
	   t.day_of_the_week,
	   t.day_of_the_year,
	   t.week_number,
	   t.quarter,
	   t.la_local_time
FROM los_angeles_accidents_staging AS l
JOIN time AS t
    ON t.start_time = l.start_time


-- Let's reduce and group the accidents hourly and not on exact minute
UPDATE los_angeles_accidents_staging
SET start_time = date_trunc('hour', start_time);

select * from los_angeles_accidents_staging

-- 5. Star Schema

-- Star Schema

-- location_dim
CREATE VIEW location_dim AS 
SELECT ROW_NUMBER() OVER (ORDER BY street, start_lng, start_lat) AS location_id,
       street,
       start_lng,
	   start_lat
FROM 
 (SELECT DISTINCT street, start_lat, start_lng
        FROM los_angeles_accidents_staging) AS l

-- date_time
CREATE VIEW date_dim AS
SELECT ROW_NUMBER() OVER (ORDER BY start_time)AS date_id,
       start_time,
       EXTRACT(DAY FROM start_time) AS day,
       EXTRACT(MONTH FROM start_time) AS month,
	   EXTRACT(YEAR FROM start_time) AS year,
	   EXTRACT(DOW FROM start_time) AS day_of_the_week,
	   EXTRACT(DOY FROM start_time) AS day_of_the_year,
	   EXTRACT(WEEK FROM start_time) AS week_number,
	   EXTRACT(QUARTER FROM start_time) AS quarter,
	   (start_time AT TIME ZONE 'America/Los_Angeles')::time AS la_hourly_local_time
FROM
 (SELECT DISTINCT start_time
       FROM los_angeles_accidents_staging) AS d

-- weather_dim
CREATE VIEW weather_dim AS
SELECT ROW_NUMBER() OVER(ORDER BY weather_condition, sunrise_sunset, civil_twilight, nautical_twilight) AS weather_id,
       weather_condition,
	   sunrise_sunset,
	   civil_twilight,
	   nautical_twilight
FROM 
 (SELECT DISTINCT weather_condition, sunrise_sunset, civil_twilight, nautical_twilight
       FROM los_angeles_accidents_staging) AS w

-- road_feature_dim
CREATE VIEW road_feaure_dim AS
SELECT ROW_NUMBER() OVER(ORDER BY amenity, bump, crossing, give_way, junction, no_exit, railway, roundabout, station, stop, traffic_calming, traffic_signal, turning_loop) AS road_feature_id,
       amenity,
	   bump,
	   crossing,
	   give_way,
	   junction,
	   no_exit,
	   railway,
	   roundabout,
	   station,
	   stop,
	   traffic_calming,
	   traffic_signal,
	   turning_loop
FROM 
 (SELECT DISTINCT amenity, bump, crossing, give_way, junction, no_exit, railway, roundabout, station, stop, traffic_calming, traffic_signal, turning_loop
      FROM los_angeles_accidents_staging) AS f

-- fact table 
ALTER TABLE los_angeles_accidents_staging
ADD COLUMN date_id INT,
ADD COLUMN weather_id INT,
ADD COLUMN location_id INT,
ADD COLUMN road_feature_id INT;


select * from los_angeles_accidents_staging
select * from date_dim

-- Time
UPDATE los_angeles_accidents_staging AS f
SET date_id = t.date_id
FROM date_dim AS t
WHERE f.start_time = t.start_time;

select * from los_angeles_accidents_staging

-- Location
UPDATE los_angeles_accidents_staging AS f
SET location_id = l.location_id
FROM location_dim AS l
WHERE f.street = l.street
  AND f.start_lat = l.start_lat
  AND f.start_lng = l.start_lng;

-- Road features
UPDATE los_angeles_accidents_staging AS f
SET road_feature_id = r.road_feature_id
FROM road_feaure_dim AS r
WHERE f.amenity = r.amenity
  AND f.bump = r.bump
  AND f.crossing = r.crossing
  AND f.give_way = r.give_way
  AND f.junction = r.junction
  AND f.no_exit = r.no_exit
  AND f.railway = r.railway
  AND f.roundabout = r.roundabout
  AND f.station = r.station
  AND f.stop = r.stop
  AND f.traffic_calming = r.traffic_calming
  AND f.traffic_signal = r.traffic_signal
  AND f.turning_loop = r.turning_loop;


UPDATE los_angeles_accidents_staging AS f
SET weather_id = w.weather_id
FROM weather_dim AS w
WHERE f.weather_condition = w.weather_condition
  AND f.sunrise_sunset = w.sunrise_sunset
  AND f.civil_twilight = w.civil_twilight
  AND f.nautical_twilight = w.nautical_twilight;
  
select * from los_angeles_accidents_staging

select * from location_dim

-- Let's skip this part cause it takes ages to load. 
CREATE VIEW fact_table_test AS
SELECT f.id AS accident_id,
	   d.date_id,
	   l.location_id,
	   r.road_feature_id,
	   w.weather_id,
	   f.severity,
	   f.temperature_f,
	   f.humidity_percentage,
	   f.wind_speed_mph,
	   f.precipitation_in
FROM los_angeles_accidents_staging as f
-- Join time dimension
JOIN date_dim AS d
 ON f.start_time = d.start_time
-- Join location dimension
JOIN location_dim AS l
 ON  f.street = l.street
AND f.start_lat = l.start_lat
AND f.start_lng = l.start_lng
-- Join road feature dimension
JOIN road_feaure_dim AS r
 ON f.amenity = r.amenity
AND f.bump = r.bump
AND f.crossing = r.crossing
AND f.give_way = r.give_way
AND f.junction = r.junction
AND f.no_exit = r.no_exit
AND f.railway = r.railway
AND f.roundabout = r.roundabout
AND f.station = r.station
AND f.stop = r.stop
AND f.traffic_calming = r.traffic_calming
AND f.traffic_signal = r.traffic_signal
AND f.turning_loop = r.turning_loop
-- Join weather dimension
JOIN weather_dim AS w
 ON f.weather_condition = w.weather_condition
AND f.sunrise_sunset = w.sunrise_sunset
AND f.civil_twilight = w.civil_twilight
AND f.nautical_twilight = w.nautical_twilight

-- Since we have already included everything in the los_angeles_accidents_staging, let's create the fact table from there 
CREATE VIEW fact_table AS
SELECT id AS accident_id,
       date_id,
	   weather_id,
	   location_id,
	   road_feature_id,
	   severity,
	   temperature_f,
	   humidity_percentage,
	   wind_speed_mph,
	   precipitation_in	   
FROM los_angeles_accidents_staging


