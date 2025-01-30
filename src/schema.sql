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
    email TEXT UNIQUE NOT NULL CHECK (email LIKE '%_.%_@email.com'), -- All member emails should end with ._email.com
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

CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('Cardio', 'Strength')),
    purchase_date TEXT NOT NULL,
    last_maintenance_date TEXT NOT NULL CHECK(last_maintenance_date >= purchase_date), -- Last Maintenance should not be before purchase
    next_maintenance_date TEXT NOT NULL CHECK(next_maintenance_date >= last_maintenance_date), -- Next maintenance should be afetr the last maintenance date
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE 
);

CREATE TABLE classes (
    class_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    capacity INTEGER NOT NULL, 
    duration INTEGER NOT NULL, 
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    class_id INTEGER,
    staff_id INTEGER,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL CHECK(end_time > start_time), -- End time of class should be after start time
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    type TEXT NOT NULL CHECK(type IN ('Premium', 'Basic')),
    start_date TEXT NOT NULL, 
    end_date TEXT NOT NULL CHECK(end_date > start_date), -- Membership end date must be in the future
    status TEXT NOT NULL CHECK(status IN ('Active', 'Inactive')),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    location_id INTEGER,
    check_in_time TEXT NOT NULL,
    check_out_time TEXT CHECK(check_out_time > check_in_time), -- Check out time should be after check in time
    FOREIGN KEY (member_id) REFERENCES members(member_id) 
    ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) 
    ON DELETE CASCADE
);

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY,
    schedule_id INTEGER,
    member_id INTEGER,
    attendance_status TEXT NOT NULL CHECK(attendance_status IN ('Registered', 'Attended', 'Unattended')),
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    amount REAL NOT NULL CHECK(amount > 0), -- Payment should be positive
    payment_date TEXT NOT NULL,
    payment_method TEXT NOT NULL CHECK(payment_method IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Cash')),
    payment_type TEXT NOT NULL CHECK(payment_type IN ('Monthly membership fee', 'Day pass')),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE SET NULL
);

CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    staff_id INTEGER,
    session_date TEXT NOT NULL, 
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL CHECK(end_time > start_time), -- end time should be after start time
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    measurement_date TEXT NOT NULL, 
    weight REAL NOT NULL,
    body_fat_percentage REAL,
    muscle_mass REAL, 
    bmi REAL,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE equipment_maintenance_log (
    log_id INTEGER PRIMARY KEY,
    equipment_id INTEGER,
    maintenance_date TEXT NOT NULL,
    description TEXT NOT NULL,
    staff_id INTEGER,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
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
