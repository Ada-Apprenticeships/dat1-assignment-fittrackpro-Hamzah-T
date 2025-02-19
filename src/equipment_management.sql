-- Initial SQLite setup
.open fittrackpro.db
.mode column

-- Enable foreign key support
PRAGMA foreign_keys = ON;
-- Equipment Management Queries

-- 1. Find equipment due for maintenance
-- TODO: Write a query to find equipment due for maintenance

SELECT equipment_id, 
       name, 
       next_maintenance_date
FROM equipment
WHERE next_maintenance_date BETWEEN date('now') 
AND date('now', '+30 days');

-- 2. Count equipment types in stock
-- TODO: Write a query to count equipment types in stock

SELECT type AS equipment_type, 
       COUNT(*) AS count
FROM equipment
GROUP BY type;

-- 3. Calculate average age of equipment by type (in days)
-- TODO: Write a query to calculate average age of equipment by type (in days)

SELECT type AS equipment_type, 
       ROUND(AVG(julianday('now') - julianday(purchase_date)),1) AS avg_age_days --juliandays used to quantify the number of days between now and purchase date
FROM equipment
GROUP BY type;