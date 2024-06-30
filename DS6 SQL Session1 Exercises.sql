-- SELECT
use telco;
-- Exercise: Retrieve all columns and rows from the `customer` table
select * 
from Customer;

-- Exercise: List only the names and subscription dates of the customer.

select first_name, last_name, subscription_date
from customer;

select avg(subscription_date) as date
from customer;

select subscription_date as `date`, first_name as `name`
from customer;

-- Exercise: Fetch all unique email addresses from the `customer` table and then count the number of unique email ids 

select distinct email
from customer;

select count(email)
from customer;



-- Exercise: Display all columns from the `billing` table.

select *
from billing;

-- Exercise: Show only the bill ID and the amount due from the `billing` table.
 select bill_id, amount_due
 from billing;
 
-- WHERE

--  Exercise: Identify customer who live at "209 Pond Hill"
 select * 
 from customer
 where address = "209 Pond Hill";
 
--  Exercise: Find bills in the `billing` table with an amount_due greater than 1000.

select * 
from billing
where amount_due > 1000;

--  Exercise: Find all the late fee less than 500

select * 
from billing
where late_fee < 500;

--  Show bills that were generated for `customer_id' 5
 
 select *
 from billing
 where customer_id = 5;
 
-- WHERE with (IN, OR, AND, NOT EQUAL TO, NOT IN)

-- Exercise: Identify customer who live at either '5 Northridge Road', '814 Kinsman Lane’

select *
from customer
where address = '5 Northridge Road' and address = '814 Kinsman Lane';

select *
from customer
where address in('5 Northridge Road','814 Kinsman Lane');

-- Exercise: Identify customer who live at either '5 Northridge Road', '814 Kinsman Lane and their phone_number starts with 277.

select *
from customer
where address in('5 Northridge Road','814 Kinsman Lane') and phone_number like '277%';

select *
from customer
where phone_number like '%277%';

select *
from customer
where phone_number like '_50%';

select *
from customer
where address like '%road';

-- select customers whose name start with an A or a D and who have 72 in their phone number

select first_name, phone_number
from customer
where (first_name like 'A%' or first_name like 'D%') and phone_number like ('%72%');

select first_name, phone_number
from customer
where (first_name like 'A%' or first_name like 'D%') and phone_number like ('%72%')
order by first_name asc;

-- Exercise: using or and AND

-- Exercise: Display customer whose phone number is NOT '123-456-7890'.

select * 
from customer
where Phone_number <> 8728496538;

-- Exercise: List all bills except those with billing cycles in "January 2023" and "February 2023"

select *
from billing
where billing_cycle not in ('23-jan','23-feb');


-- ORDER BY

-- Exercise: Order customer by their names in ascending order

select *
from customer
order by first_name desc;

select *
from customer
order by subscription_date asc, last_name asc; -- multi-level sorting


-- Exercise: Display bills from the `billing` table ordered by `amount_due` in descending order.

select *
from billing
order by amount_due desc;

-- LIMIT

-- Exercise: Show only the first 10 customer.

select *
from customer
limit 10;
-- Exercise: List the top 5 highest bills from the `billing` table.

select * from billing;
select * from billing
order by amount_due desc
limit 5;

-- Exercise: Retrieve the latest 3 bills based on the due date.

select *
from billing
order by due_date desc
limit 3;


