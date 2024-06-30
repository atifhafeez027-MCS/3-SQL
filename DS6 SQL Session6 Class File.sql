-- group by collapses data
select customer_id, service_type, count(customer_id)
from service_usage
group by customer_id, service_type
order by 1;

-- without group by, you cannot fetch non-aggregated columns along with aggregate columns, so the following query gives an error 
select *,
avg(data_used),
max(minutes_used)
from service_usage;

-- but WINDOW functions makes this possible.
-- here, the over clause is empty so the window is the whole column. You get avg and max of the whole column along with unaggregated columns from *
select *,
avg(data_used) over(),
max(minutes_used) over()
from service_usage
order by usage_id;

-- with a partition inside over(), you get the aggregates PER that partition. In the following case, per customer 
select *,
avg(data_used) over(partition by customer_id) as customer_avg, 
max(data_used) over(partition by customer_id) as customer_max,
count(customer_id) over(partition by customer_id) as customer_count
from service_usage
order by customer_id;

-- Partitioning based on TWO columns
select *,
avg(data_used) over(partition by customer_id, service_type) as avg_per_customer_per_service, 
max(data_used) over(partition by customer_id, service_type) as max_per_customer_per_service,
count(customer_id) over(partition by customer_id, service_type) as count_per_customer_per_service
from service_usage
order by customer_id;



-- PARTITION BY
-- Exercise 1: Find the number of feedback entries for each service type for each customer

-- Exercise 2: Calculate the Average data_used for each service_type for each customer


-- RANK() and DENSE_RANK()

-- Exercise 1: Rank each customer inside each service_type to show top customers with most data used in each service_type

-- Exercise 1: Rank customers according to the number of services they have subscribed to

-- Exercise 2:Rank customers based on the total sum of their ranking they have ever given.


-- LEAD():
-- Exercise 1:View next session’s data usage for each customer

-- Exercise 2:Calculate the difference in data usage between the current and next session.


-- LAG():
-- Exercise 1:Review Previous Session's Data Usage

-- Exercise 2:Interval Between Service Usage Sessions



-- Common Table Expressions (CTEs)
-- Exercise1: display avg data_used for each customer for each record in feedback

with averages as (

select customer_id as id, avg(data_used) as average_data_used
from service_usage
group by customer_id

)

select f.*, a.average_data_used
from feedback f
join averages a on f.customer_id = a.id;



-- syntax to define multiple ctes
-- NOTE: it is unnecessary to do the following with two CTEs though. 
-- You could have just gotten max(data_used) and avg(data_used) in a single CTE as both come from service_usage

with averages as (

select customer_id as id, avg(data_used) as average_data_used, max(data_used) as max_data_used
from service_usage
group by customer_id

), 

maxes as (

select customer_id as id, max(data_used) as maxes
from service_usage
group by customer_id

)

select f.*, a.average_data_used, m.maxes
from feedback f
join averages a on f.customer_id = a.id
join maxes m on f.customer_id = m.id;


-- Exercise 2:Find customers who consistently use more data than average.




-- Exercise 3: find out the most recent feedback from each customer.
with max_dates as (

select customer_id, max(feedback_date) as latest_date
from feedback
group by customer_id

)

select f.customer_id, f.feedback_text, f.rating, m.latest_date
from feedback f
join max_dates m on f.customer_id = m.customer_id and f.feedback_date = m.latest_date;


-- Exercise 4: Find customer name and id for all customers with length of subscription more than 4000 days

with subscription_lengths as(

select customer_id, datediff(end_date, start_date) as sub_length
from subscriptions
where datediff(end_date, start_date) > 4000
)

select c.first_name, c.last_name, sl.sub_length
from customer c
join subscription_lengths sl on c.customer_id = sl.customer_id;


-- Exercise 5: Find out all the customers who have more than one record in feedback, that also have more than one record in service_usage. 







