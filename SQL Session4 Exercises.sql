
select * from feedback order by customer_id;
select * from service_usage order by customer_id;

-- Inner Join / Join

select su.customer_id, su.data_used, f.feedback_text
from service_usage su 
inner join feedback f
on su.customer_id = f.customer_id
order by 1;

select su.customer_id, su.data_used, f.feedback_text
from service_usage su 
join feedback f
on su.customer_id = f.customer_id
order by 1;

select su.customer_id, su.data_used, f.feedback_text
from service_usage as su 
join feedback as f
on su.customer_id = f.customer_id
order by 1;

-- Left Join

select su.customer_id, su.data_used, f.feedback_text
from service_usage su 
left join feedback f
on su.customer_id = f.customer_id;

-- Right Join

select su.customer_id, su.data_used, f.feedback_text
from service_usage su 
right join feedback f
on su.customer_id = f.customer_id;

-- INNER JOIN
-- Exercise 1: 
-- Write a query to find all customers along with their billing information.

select * from customer;
select * from billing;

select c.customer_id, c.last_name, b.amount_due, b.payment_date
from customer c
join billing b
on c.customer_id = b.Customer_id;

select c.*, b.*
from customer c
join billing b
on c.customer_id = b.Customer_id;

-- Exercise 2:
-- List all customers with their corresponding total due amounts from the billing table.

select * from billing;

select c.customer_id, sum(b.amount_due) as Total_Amount_Due
from customer c
join billing b
on c.customer_id = b.customer_id
group by c.customer_id
order by c.customer_id;

select c.customer_id, sum(amount_due) as Total_Amount_Due -- if we write amount_due instead of b.amount due, it will
from customer c										      -- give correct result because we have only one amount_due
join billing b											  -- column. But customer_Id withlout alias will give error as
on c.customer_id = b.Customer_id						  -- it is present in both columns
group by c.customer_id
order by c.Customer_id;


-- Exercise 3:
-- Display service packages along with the number of subscriptions each has.

select * from service_packages;
select * from subscriptions;

-- select distinct package_id from service_packages;
-- select distinct subscription_id from subscriptions;

select sp.package_id, sp.package_name, s.subscription_id
from service_packages sp
join subscriptions s on sp.package_id = s.package_id
order by 1;

select sp.package_id, count(s.subscription_id) as No_of_Subscriptions
from service_packages sp
join subscriptions s
on sp.package_id = s.package_id
group by sp.package_id
order by 1;

-- LEFT JOIN
-- Exercise 1:
-- Write a query to list all customers and any feedback they have given, including customers who have not given feedback.

select c.customer_id,c.First_name, c.Last_name, f.feedback_text
from customer c
left join feedback f
on c.customer_id = f.customer_id;

-- Exercise 2:
-- Retrieve all customer and the package names of any subscriptions they might have.

select c.customer_id, c.last_name, s.package_id, sp.package_name
from customer c
left join subscriptions s on c.customer_id = s.customer_id
left join service_packages sp on s.package_id = sp.package_id;

--  Exercise 3:
-- Find out which customer have never given feedback by left joining customer to feedback.

select c.customer_id, c.first_name, f.feedback_id, f.feedback_text
from customer c
left join feedback f
on c.customer_id = f.customer_id
where feedback_text is null; 

-- now if we want to know how many customer has given feedback using left join?

select c.customer_id, count(f.feedback_id) as No_of_Feedbacks
from customer c
left join feedback f
on c.customer_id = f.customer_id
group by c.customer_id
order by 1;

-- RIGHT JOIN
-- Exercise 1: 
-- Write a query to list all feedback entries and the corresponding customer information, including feedback without a linked customer.

select c.customer_id,c.First_name, c.Last_name, f.feedback_text
from customer c
right join feedback f
on c.customer_id = f.customer_id;

select f.feedback_id, f.feedback_text, c.customer_id, c.last_name 
from customer c
right join feedback f
on c.customer_id = f.customer_id;		-- same result as of above query

-- Exercise 2:
-- Show all feedback entries and the full names of the customer who gave them.

select f.feedback_text, c.first_name, c.last_name
from customer c
right join feedback f
on c.customer_id = f.customer_id;

-- Exercise 3:
-- List all customers, including those without a linked service usage.

select c.customer_id, s.data_used
from service_usage s
right join customer c on s.customer_id = c.customer_id;

-- Multiple JOINs
-- Exercise 1:
-- Write a query to list all customer, their subscription packages, and usage data.

select * from subscriptions;
select * from service_packages;

select c.customer_id, c.first_name, su.data_used, su.minutes_used, sp.package_name
from customer c
join service_usage su on c.customer_id = su.customer_id
join subscriptions s on s.customer_id = su.customer_id
join service_packages sp on sp.package_id = s.package_id; -- Why 1023 rows?

select c.customer_id, c.first_name, su.data_used, su.minutes_used, sp.package_name
from customer c
left join service_usage su on c.customer_id = su.customer_id -- left join for all customers
left join subscriptions s on s.customer_id = su.customer_id
left join service_packages sp on sp.package_id = s.package_id;

-- Subqueries
-- Exercise 1: 
-- Single-row Subquery. Write a query to find the service package with the highest monthly rate.

select * from service_packages;

select max(monthly_rate)
from service_packages;

select package_id, package_name, monthly_rate
from service_packages
where monthly_rate = (select max(monthly_rate) from service_packages);


--  Exercise 2:
-- Find the customer with the smallest total amount of data used in service_usage.

select customer_id, data_used
from service_usage
where data_used = (select min(data_used) from service_usage);

-- if we need info from other tables i.e customer id, name etc, we can do with sub queries without joins

select customer_id, first_name, last_name
from customer
where customer_id = (
select customer_id
from service_usage
where data_used = (select min(data_used) from service_usage)
);

-- Now with the join

select c.customer_id, c.first_name, c.last_name, su.data_used
from customer c
join service_usage su
on c.customer_id = su.customer_id
where data_used = (select min(data_used) from service_usage);

-- Exercise 3:
-- Identify the service package with the lowest monthly rate.

select package_id, package_name, monthly_rate
from service_packages
where monthly_rate = (select min(monthly_rate) from service_packages);

-- Above was comparison of one value agains one value, but if the inner sub query return multiple values, we will use IN

-- Exercise 4: 
-- In service_usage, label data usage as ‘High’ if above the average usage, ‘Low’ if below.

select *,
case
	when data_used > (select Avg(data_used) from service_usage) then 'High'
    else 'Low'
    end as Usage_Pri
from service_usage
order by customer_id;

-- Multiple-row Subquery
-- Exercise 1 :
-- Find customers whose subscription lengths are longer than the average subscription length of every individual customer.



-- Multiple-column Subquery
-- Exercise 1:
-- Select all feedback entries that match the worst rating given for any service type.


-- Correlated Subquery
-- Exercise 1:
-- List all packages and information for packages with monthly rates are less than the maximum minutes used for each service type.

-- Exercise2:
-- Find customers who have at least one billing record with an amount due that is greater than their average billing amount.


-- Subquery in SELECT
-- Exercise 1:
-- Write a query to show each customer's name and the number of subscriptions they have.





