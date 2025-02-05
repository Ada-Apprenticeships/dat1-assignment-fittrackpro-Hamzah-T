-- Initial SQLite setup
.open fittrackpro.db
.mode column

-- Enable foreign key support

-- Membership Management Queries

-- 1. List all active memberships
-- TODO: Write a query to list all active memberships

SELECT m.member_id, 
       m.first_name, 
       m.last_name, 
       me.type AS membership_type, 
       m.join_date
FROM members m
JOIN memberships me ON m.member_id = me.member_id
WHERE me.status = 'Active';

-- 2. Calculate the average duration of gym visits for each membership type
-- TODO: Write a query to calculate the average duration of gym visits for each membership type

SELECT me.type AS membership_type,
       AVG(strftime('%s', a.check_out_time) - strftime('%s', a.check_in_time)) / 60 AS avg_visit_duration_minutes
FROM attendance a
JOIN memberships me ON a.member_id = me.member_id
WHERE a.check_out_time IS NOT NULL  -- Exclude ongoing visits
GROUP BY me.type;

-- 3. Identify members with expiring memberships this year
-- TODO: Write a query to identify members with expiring memberships this year

SELECT m.member_id, 
       m.first_name, 
       m.last_name, 
       m.email, 
       me.end_date
FROM members m
JOIN memberships me ON m.member_id = me.member_id
WHERE me.end_date BETWEEN date('now') AND date('now', '+1 year');
