-- Define a SQL table to store information about space missions. 
CREATE TABLE spacemissions (
  company VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  date DATE,
  time TIME,
  rocket VARCHAR(255),
  mission VARCHAR(255),
  rocket_status VARCHAR(255),
  price decimal (15,2) ,
  mission_status VARCHAR(255)
);


COPY spacemissions FROM 'C:\Program Files\PostgreSQL\16\data\Data-Resource\space.csv' DELIMITER ',' CSV HEADER;



select * from spacemissions

-- Retrieve the names of all rockets used in space missions. 

select distince rocket from 
spacemissions ; 

-- Display the details of space missions launched by a specific company

select * from spacemissions 
where 
company like 'NASA' ;

-- Retrieve the top 5 most expensive rockets based on their cost. 
select rocket 
order by price
limit 5 ;

--  Calculate the average cost of all rockets. 
select avg(price) as avg_cost
from spacemissions ; 

--  Group the missions by launch location and display the total count of missions for each location. 

select location , count(mission) as total_missions
from spacemissions
group by location
order by total_missions desc ;

-- Create a new table for rocket details and join it with the main table to display mission names and their 
-- -- corresponding rocket names. 
select * from spacemissions
create table rockets (
rocket varchar ,
mission varchar 
);

copy rockets (rocket , mission) 
from 'C:\Program Files\PostgreSQL\16\data\Data-Resource\space.csv' DELIMITER ',' CSV HEADER;

-- Find the company that conducted the most expensive mission. 
-- Method1 
select company , price
from spacemissions 
where price is not null 
order by price desc
limit 1 ;

-- Method2
select company , max(price)
from spacemissions
where price is not null
group by company 
order by max(price) desc
limit 1

-- Method3
select company , price as max_price 
from spacemissions 
where 
price = (select max(price) from spacemissions)
 
 
--  Calculate the total cost of successful missions.
select sum(price) as total_cost
from spacemissions 
where mission_status like 'Success'
and price is not null ;

--  Change the status of rockets to 'Inactive' for those whose mission status is 'Prelaunch Failure'. 
select * from spacemissions
update  spacemissions
set rocket_status = 'Inactive'
where mission_status like 'Prelaunch Failure' ;

-- Create a new column 'Mission_Result' that categorizes missions as 'Successful', 'Partial Success', or 
-- -- 'Failed' based on their mission status
select distinct mission_status
from spacemissions

select * ,
	case when  mission_status like 'Prelaunch Failure' and mission_status like ' Failure'
	then  'Failed' 
	when mission_status like 'Partial Failure'    
	then 'Partial Success'
	else 
	'Successful' 
	end as Mission_Result
	from spacemissions

-- Rank the missions based on their launch date within each company. 
--         [We will have to use window function ]
select company , date ,
rank() over(partition by company order by date ) 
from spacemissions   

-- Calculate the running total of the number of missions conducted by each company. 
select company , 
count(mission) over (partition by company order by date)
as total 
from spacemissions
order by company , date ;

-- Create a CTE that lists companies along with the count of their successful missions. 

select * from spacemissions

with cte as (
select company , count (mission) as successful_missions
from spacemissions
where mission_status like 'Success' 
group by company 
order by count(mission) desc 
	)
select * from cte

--  Pivot the data to show the total count of missions for each company and their mission statuses. 
select company,
sum(case when  mission_status like 'Partial Failure' then 1 else 0 end  ) as Partial_Failure ,
sum (case when  mission_status like 'Success' then 1 else 0 end  ) as Success ,
sum (case when  mission_status like 'Prelaunch Failure' then 1 else 0 end  ) as Prelaunch_Failure ,
sum (case when  mission_status like 'Failure' then 1 else 0 end  ) as Failure ,
count (*) as total_missions
from spacemissions 
group by company ;

--  Unpivot the table to transform the 'Mission_Result' column into a single column named 'Result'. 
??????????????????????????????????
select company , 'Success' as result ,
count(mission_status) as count
from spacemissions
where mission_status like 'Success'
group by company

union all

select company , 'Partial Failure' as result ,
count(mission_status) as count
from spacemissions
where mission_status like 'Partial Failure'
group by company

union all

select company , 'Prelaunch Failure' as result ,
count(mission_status) as count
from spacemissions
where mission_status like 'Prelaunch Failure'
group by company

union all

select company , 'Failure' as result ,
count(mission_status) as count
from spacemissions
where mission_status like 'Failure'
group by company



select distinct mission_status from spacemissions

-- Create a stored procedure that accepts a location as input and returns the total count of missions 
--    launched from that location. 
 CREATE OR REPLACE FUNCTION total_mission_location(loc VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    total_missions INTEGER;
BEGIN
    SELECT COUNT(mission) INTO total_missions
    FROM space_mission
    WHERE location = loc;
    RETURN total_missions;
END;
$$ LANGUAGE plpgsql;


call total_mission_location ;


