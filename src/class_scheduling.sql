-- Initial SQLite setup
.open fittrackpro.db
.mode column

-- Enable foreign key support

-- Class Scheduling Queries

-- 1. List all classes with their instructors
-- TODO: Write a query to list all classes with their instructors

SELECT c.class_id, 
       c.name AS class_name, 
       s.first_name || ' ' || s.last_name AS instructor_name --Retrieve first and last name of instructor and combine to get full name
FROM classes c
JOIN class_schedule cs 
ON c.class_id = cs.class_id
JOIN staff s 
ON cs.staff_id = s.staff_id;

-- 2. Find available classes for a specific date
-- TODO: Write a query to find available classes for a specific date

SELECT cs.class_id, 
       c.name, 
       cs.start_time, 
       cs.end_time,
       (c.capacity - COUNT(ca.member_id)) AS available_spots
FROM class_schedule cs
JOIN classes c 
ON cs.class_id = c.class_id
LEFT JOIN class_attendance ca 
ON cs.schedule_id = ca.schedule_id
WHERE date(cs.start_time) = '2025-02-01'
GROUP BY cs.schedule_id
HAVING available_spots > 0;  -- Ensures only classes with available spots are shown

-- 3. Register a member for a class
-- TODO: Write a query to register a member for a class

INSERT INTO class_attendance (schedule_id, member_id, attendance_status)
SELECT cs.schedule_id, 11, 'Registered'
FROM class_schedule cs
WHERE cs.class_id = 3 AND date(cs.start_time) = '2025-02-01'
AND NOT EXISTS (SELECT 1 
                FROM class_attendance ca 
                WHERE ca.schedule_id = cs.schedule_id AND ca.member_id = 11) -- Prevent double registration of this member for one class
LIMIT 1;

-- 4. Cancel a class registration
-- TODO: Write a query to cancel a class registration

DELETE FROM class_attendance
WHERE schedule_id = 7 AND member_id = 2;


-- 5. List top 5 most popular classes
-- TODO: Write a query to list top 5 most popular classes

SELECT c.class_id, 
       c.name AS class_name, 
       COUNT(ca.member_id) AS registration_count
FROM classes c
JOIN class_schedule cs 
ON c.class_id = cs.class_id
JOIN class_attendance ca 
ON cs.schedule_id = ca.schedule_id
GROUP BY c.class_id
ORDER BY registration_count DESC
LIMIT 3;

-- 6. Calculate average number of classes per member
-- TODO: Write a query to calculate average number of classes per member

SELECT COUNT(*) / (SELECT COUNT(DISTINCT member_id) FROM members) AS avg_classes_per_member
FROM class_attendance;
