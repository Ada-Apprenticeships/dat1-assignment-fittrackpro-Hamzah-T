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
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number CHAR(8) NOT NULL CHECK(phone_number LIKE '555-____'), -- All Numbers should start with 555- and follow with 4 digits
    email VARCHAR(255) UNIQUE NOT NULL CHECK(email LIKE '%_@fittrackpro.com'), -- All Location emails should end with @fittrackpro.com 
    opening_hours VARCHAR(12) NOT NULL --Format is h:mm-hh:mm so 12 accounts for this plus an extra character at the start
);

CREATE TABLE members(
    member_id INTEGER PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%_@email.com'), -- Check all member emails end in @email.com 
    phone_number CHAR(8) NOT NULL CHECK(phone_number LIKE '555-____'),
    date_of_birth DATE NOT NULL,
    join_date DATE NOT NULL CHECK(join_date >= date_of_birth),
    emergency_contact_name VARCHAR(255) NOT NULL,
    emergency_contact_phone CHAR(8) NOT NULL CHECK(emergency_contact_phone LIKE '555-____')
);

CREATE TABLE staff(
    staff_id INTEGER PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%_._@fittrackpro.com'),--All staff emails should end with ._fittrackpro.com
    phone_number CHAR(8) NOT NULL CHECK(phone_number LIKE '555-____'),
    position VARCHAR(12) NOT NULL CHECK(position IN ('Trainer', 'Manager', 'Receptionist', 'Maintenance')),-- Maximum length possible is 12
    hire_date DATE NOT NULL,
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE --Ensures location_id changes update all dependent records accordingly
    ON DELETE SET NULL -- Prevents orphaned records by setting location_id to NULL when location is deleted
);

CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(8) NOT NULL CHECK(type IN ('Cardio', 'Strength')),--Maximum length it can be is 8
    purchase_date DATE NOT NULL,
    last_maintenance_date DATE NOT NULL CHECK(last_maintenance_date >= purchase_date), -- Last Maintenance should not be before purchase
    next_maintenance_date DATE NOT NULL CHECK(next_maintenance_date >= last_maintenance_date), -- Next maintenance should be afetr the last maintenance date
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE 
);

CREATE TABLE classes (
    class_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    capacity INTEGER NOT NULL, 
    duration INTEGER NOT NULL, 
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    class_id INTEGER,
    staff_id INTEGER,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL CHECK(end_time > start_time), -- End time of class should be after start time
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    type VARCHAR(7) NOT NULL CHECK(type IN ('Premium', 'Basic')),--Maximum length it can be is 7
    start_date DATE NOT NULL, 
    end_date DATE NOT NULL CHECK(end_date > start_date), -- Membership end date must be in the future
    status VARCHAR(8) NOT NULL DEFAULT 'Active' CHECK(status IN ('Active', 'Inactive')), -- Set default value as active for new memberships which are added
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    location_id INTEGER,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME CHECK(check_out_time > check_in_time), -- Check out time should be after check in time
    FOREIGN KEY (member_id) REFERENCES members(member_id) 
    ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) 
    ON DELETE CASCADE
);

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY,
    schedule_id INTEGER,
    member_id INTEGER,
    attendance_status VARCHAR(10) NOT NULL DEFAULT 'Registered' CHECK(attendance_status IN ('Registered', 'Attended', 'Unattended')), -- Default value should be registered where no value is assigned
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    amount REAL NOT NULL CHECK(amount > 0), -- Payment should be positive
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- For any new payments with no date or time specified, the current date and time is the default value
    payment_method VARCHAR(13) NOT NULL CHECK(payment_method IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Cash')),
    payment_type VARCHAR(22) NOT NULL CHECK(payment_type IN ('Monthly membership fee', 'Day pass')),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE SET NULL
);

CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    staff_id INTEGER,
    session_date DATE NOT NULL, 
    start_time TIME NOT NULL,
    end_time TIME NOT NULL CHECK(end_time > start_time), -- end time should be after start time
    notes VARCHAR(255) DEFAULT NULL, --Default shoudl be null for any sessions which have no notes rather than empty
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY,
    member_id INTEGER,
    measurement_date DATE NOT NULL, 
    weight REAL NOT NULL,
    body_fat_percentage REAL,
    muscle_mass REAL, 
    bmi REAL,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

CREATE TABLE equipment_maintenance_log (
    log_id INTEGER PRIMARY KEY,
    equipment_id INTEGER,
    maintenance_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
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
