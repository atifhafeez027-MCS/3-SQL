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
avg(data_used) over(partition by service_type) as service_type_avg, 
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

-- rank uses order by in the over() clause to assign rank based on the order of a column/multiple columns
select customer_id, data_used
from service_usage
order by data_used desc;

-- your rank is assigned based on data_used in descending order
select customer_id, data_used, minutes_used,
rank() over(order by data_used desc)
from service_usage
order by customer_id;

-- here, rank is assigned to each row as if your data is ordered by customer_id in descending order (1000 to 1) 
-- and within each customer id, the records are ordered by minutes_used ascending
select customer_id, data_used, minutes_used,
rank() over(order by customer_id desc, minutes_used asc)
from service_usage;

-- you can also use aggregate functions like sum, avg, etc with order by in window functions
-- sum() will give you a running total 
select customer_id, data_used,
sum(data_used) over(order by data_used desc)
from service_usage;

select customer_id, data_used,
sum(data_used) over(partition by customer_id order by data_used)
from service_usage;


-- in order to use columns with window functions in the where clause, you need a CTE

-- Find out the date and the minimum amount_due on that date that brought the company's total revenue to 1 million
with running_total as (

select customer_id, payment_date, amount_due,
sum(amount_due) over(order by payment_date, amount_due) as r_tot
from billing
where payment_date is not null

)

select customer_id, payment_date, amount_due
from running_total
where r_tot > 1000000
limit 1;


-- find out which record has the same rank in data_used as in minutes_used
with rankings as (

select *,
rank() over(order by data_used desc) as data_rank, 
rank() over(order by minutes_used desc) as minutes_rank
from service_usage
order by customer_id

)

select *
from rankings
where data_rank = minutes_rank;


-- PARTITION BY
-- Exercise 1: Find the number of feedback entries for each service type for each customer
select feedback_id, customer_id, feedback_date, service_impacted,
count(feedback_id) over(partition by service_impacted)
from feedback;


-- Exercise 2: Calculate the Average data_used for each service_type for each customer
select customer_id, service_type, 
avg(data_used) over(partition by service_type, customer_id)
from service_usage
order by customer_id;


-- RANK() and DENSE_RANK()

-- Exercise 1: Rank each customer inside each service_type to show top customers with most data used in each service_type
select customer_id, data_used, service_type,
rank() over(partition by service_type order by data_used desc)
from service_usage;

-- Exercise 1: Rank customers according to the number of services they have subscribed to
select customer_id, count(subscription_id) as total_sub,
dense_rank() over(order by count(subscription_id) desc)
from subscriptions
group by customer_id;

select customer_id, count(subscription_id) as total_sub,
rank() over(order by count(subscription_id) desc)
from subscriptions
group by customer_id;


-- Exercise 2:Rank customers based on the total sum of their rating they have ever given.
select customer_id, sum(rating),
rank() over(order by sum(rating) desc)
from feedback
group by customer_id;


-- LEAD() and LAG() functions
-- will give the next or previous value of a column based on the order you have specified inside the window 
select customer_id, data_used,
lead(data_used) over(order by customer_id desc)
from service_usage;


select customer_id, data_used,
lag(data_used) over(order by customer_id desc)
from service_usage;


-- LEAD():
-- Exercise 1:View next session’s data usage for each customer
select customer_id, usage_date, data_used as current_session,
lead(data_used) over (partition by customer_id order by usage_date) as next_session
from service_usage;


-- Exercise 2:Calculate the difference in data usage between the current and next session each customer.
select customer_id, data_used as current_session, usage_date,
lead(data_used) over (partition by customer_id order by usage_date) as next_session, 
lead(data_used) over (partition by customer_id order by usage_date) - data_used as difference
from service_usage;


-- LAG():
-- Exercise 1:Review Previous Session's Data Usage
select customer_id, usage_date, data_used as current_session,
lag(data_used) over (partition by customer_id order by usage_date) as previous_session
from service_usage;


-- Exercise 2: Interval Between Service Usage Sessions
select customer_id, data_used, usage_date as date_current,
lead(usage_date) over(partition by customer_id order by usage_date) as date_next,
datediff(lead(usage_date) over(partition by customer_id order by usage_date), usage_date)
from service_usage;


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
with from_feedback as (

select customer_id, count(feedback_id) as feedback_counts
from feedback
group by customer_id
having count(feedback_id) > 1

),

from_service_usage as (

select customer_id, count(usage_id) as usage_counts
from service_usage
group by customer_id
having count(usage_id) > 1

)

select ff.customer_id, ff.feedback_counts, fsu.usage_counts
from from_feedback ff
join from_service_usage fsu on ff.customer_id = fsu.customer_id;





