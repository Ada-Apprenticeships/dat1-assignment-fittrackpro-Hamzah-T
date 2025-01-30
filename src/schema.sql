-- FitTrack Pro Database Schema

-- Initial SQLite setup
.open fittrackpro.db
.mode column

-- Enable foreign key support
PRAGMA foreign_keys = ON;

-- Create your tables here
-- Example:
-- CREATE TABLE table_name (
--     column1 datatype,
--     column2 datatype,
--     ...
-- );

CREATE TABLE locations(
    location_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL CHECK(phone_number LIKE '555-____'), -- All Numbers should start with 555- and follow with 4 digits
    email TEXT UNIQUE NOT NULL CHECK(email LIKE '%_@fittrackpro.com'), -- All Location emails should end with @fittrackpro.com 
    opening_hours TEXT NOT NULL
);

CREATE TABLE members(
    member_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL CHECK (email LIKE '%_._@email.com'), -- All member emails should end with ._email.com
    phone_number TEXT NOT NULL CHECK(phone_number LIKE '555-____'),
    date_of_birth TEXT NOT NULL,
    join_date TEXT NOT NULL CHECK(join_date >= date_of_birth),
    emergency_contact_name TEXT NOT NULL,
    emergency_contact_phone TEXT NOT NULL CHECK(emergency_contact_phone LIKE '555-____')
);

CREATE TABLE staff(
    staff_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL CHECK (email LIKE '%_._@fittrackpro.com'),--All staff emails should end with ._fittrackpro.com
    phone_number TEXT NOT NULL CHECK(phone_number LIKE '555-____'),
    position TEXT NOT NULL CHECK(position IN ('Trainer', 'Manager', 'Receptionist', 'Maintenance')),
    hire_date TEXT NOT NULL,
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE --Ensures location_id changes update all dependent records accordingly
    ON DELETE SET NULL -- Prevents orphaned records by setting location_id to NULL when location is deleted
);




-- TODO: Create the following tables:
-- 1. locations
-- 2. members
-- 3. staff
-- 4. equipment
-- 5. classes
-- 6. class_schedule
-- 7. memberships
-- 8. attendance
-- 9. class_attendance
-- 10. payments
-- 11. personal_training_sessions
-- 12. member_health_metrics
-- 13. equipment_maintenance_log

-- After creating the tables, you can import the sample data using:
-- `.read data/sample_data.sql` in a sql file or `npm run import` in the terminal
