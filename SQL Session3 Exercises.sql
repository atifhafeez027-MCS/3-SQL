
-- Aggregating Data

-- 1. Exercise: Find the average monthly rate for each service type in service_packages. Use the ROUND function here to make result set neater

select * from service_packages;

select service_type, avg(monthly_rate) 
from service_packages
group by service_type;

select service_type, count(*), avg(monthly_rate) 		-- count (*) means count all the rows
from service_packages
group by service_type;

select service_type, count(*) as Total_Rows, round(avg(monthly_rate),2) as Avg_Monthy_Rate	-- 2 here means 2 decimal places 
from service_packages
group by service_type;

select package_name, round(avg(monthly_rate),3)
from service_packages
group by package_name;

select package_name, service_type, count(*) as Total_Rows, round(avg(monthly_rate),2) as Avg_Monthy_Rate	-- 2 here means 2 decimal places 
from service_packages
group by package_name, service_type
order by service_type;

-- 2. Exercise: Calculate the total minutes used by all customers for mobile services.

select * from service_usage;

select service_type, sum(minutes_used) as mins_used
from service_usage
group by service_type;

select service_type, sum(minutes_used) as mins_used
from service_usage
where service_type = 'mobile';

select service_type, sum(minutes_used) as mins_used
from service_usage
group by service_type
having service_type = "mobile"; -- not a sensible thing to do for this question

-- 3. Exercise: List the total number of feedback entries for each rating level.

select * from feedback;

select rating, count(feedback_id) as total_records
from feedback
group by rating
order by rating asc;

 explain format = json select rating, count(feedback_id) as total_records -- to check query execution
from feedback
group by rating
having rating != ''
order by rating asc;

select rating, count(feedback_id) as total_records
from feedback
where rating <> ''
group by rating
order by rating;

-- 4. Exercise: Calculate the total data and minutes used per customer, per service type.

select customer_id, service_type, round(sum(data_used),2) as Data_used, 
round(sum(minutes_used),2) as Mins_Used, count(*)
from service_usage
group by customer_id, service_type
order by customer_id;

-- 5. Exercise: Group feedback by service impacted and rating to count the number of feedback entries.

select * from feedback;

select service_impacted, rating, count(feedback_id) as feedback_Entries
from feedback
group by service_impacted,rating
having rating <> '' and service_impacted <> ''
order by service_impacted, rating desc;


-- HAVING clause

-- 8. Exercise: Show the total amount due by each customer, but only for those who have a total amount greater than $100.

select customer_id, sum(amount_due)
from billing
group by customer_id
having sum(amount_due) > 100;

select customer_id, sum(amount_due) as Total_Amount
from billing
group by customer_id
having Total_Amount > 100;

-- 9. Determine which customers have provided feedback on more than one type of service, but have a total rating less than 10.

select * from feedback
order by customer_id;

select distinct customer_id, count(distinct service_impacted) as No_of_Services, sum(rating) as Total_Rating
from feedback
group by customer_id, service_impacted
having Total_Rating <10
order by customer_id;			-- check again


-- Conditional Expressions and CASE Statements

-- 1. Exercise: Categorize customers based on their subscription date: ‘New’ for those subscribed after 2023-01-01, ‘Old’ for all others.

select * from customer;

select *,
case when subscription_date > '2023-01-01' then 'New'
	else 'Old'
    end as Customer_Catag
from customer;

-- 2. Exercise: Provide a summary of each customer’s billing status, showing ‘Paid’ if the payment_date is not null, and ‘Unpaid’ otherwise.

select * from billing;

select customer_id, payment_date,
case when payment_date <> '' then 'paid'
	when payment_date = 'hello' then 'what'
    else 'unpaid'
    end as payment_status
from billing;

-- 3. Exercise: From service_usage table, label data_used for each record in the following way:
-- if data_used is less than 100 - "low_usage"
-- if data_used is between 100 and 1000 - 'modererate usage'
-- if data_used is greater than 1000 - 'heavy usage'

select *,
case
	when data_used < 100 then 'low usage'
    when data_used between 100 and 1000 then 'moderate usage'
    when data_used >1000 then 'heavy usage'
end as Data_Usage
from service_usage;

-- 4. Exercise: Classify each customer based on TOTAL data_used in the following way
-- if data_used is less than 100 - 'low value'
-- if data_used is between 100 and 500 - 'moderate value'
-- if data_used is greater than or equal to 500 - 'high value'

select customer_id, round(sum(data_used),2) as total_data,
case
	when sum(data_used) < 100 then 'low value'
    when sum(data_used) between 100 and 500 then 'moderate value'
    when sum(data_used) >= 500 then 'high value'
end as usage_catagory
from service_usage
group by customer_id
order by customer_id;

select * from service_usage
order by customer_id;

-- 5. Exercise: In service_usage, label data usage as ‘High’ if above the average usage, ‘Low’ if below.


select *,
case
	when data_used > (select avg(data_used) from service_usage) then 'High'
    else 'Low'
end as Usage_Label
from service_usage;

-- 6. Exercise: For each feedback given, categorise the service_impacted into ‘Digital’ for ‘streaming’ or ‘broadband’ and ‘Voice’ for ‘mobile’.

select customer_id, service_impacted,
case when service_impacted in('streaming', 'broadband') then 'Digital'
	when service_impacted = 'mobile' then 'Voice'
    else 'Not Available'
end as Catagory
from feedback
order by customer_id;

-- 7. Exercise: Update the discounts_applied field in billing to 10% of amount_due for bills
-- with a payment_date past the due_date, otherwise set it to 5%.
-- first we will update date columns in billing table

select * from billing;

set sql_safe_updates = 0;

update billing 
set payment_date = null
where payment_date = '';  			-- query not executed, will be done using case as done below.

update billing 
set payment_date = str_to_date(payment_date, "%m/%d/%Y");	-- query not executed, will be done using case as done below.

update billing
set payment_date = 
case
	when payment_date <> '' then str_to_date(payment_date, "%m/%d/%Y")
    else null
end;										-- Query Executed and updated 

alter table billing
modify payment_date date;

update billing
set due_date = str_to_date(due_date, "%m/%d/%Y");

alter table billing
modify due_date date;

update billing
set discounts_applied = 
case
	when payment_date > due_date then round((amount_due * 0.1),2)	-- shouldn't it be payment_id < due_date?
    else round((amount_due * 0.05),2)
end;

select * from billing;

-- 8. Exercise: Classify each customer as ‘High Value’ if they have a total amount due greater than $500, or ‘Standard Value’ if not.

select customer_id, sum(amount_due),
case when sum(amount_due) > 500 then "High Value"
    else "Standard Value"
    end as Customer_Category
from billing
group by customer_id;						-- customer_id in billing table is also unique that's why 1000 rows

-- 9. Exercise: Mark each feedback entry as ‘Urgent’ if the rating is 1 and the feedback text includes ‘outage’ or ‘down’.

select * from feedback;

select *,
case
	when (rating = 1) and (feedback_text like "%outage%" or feedback_text like "%down%") then "urgent"
    else "Normal"
end as Feedback_Status
from feedback
order by 7;	

select feedback_id, feedback_text,
case
	when (rating = 1) and (feedback_text like "%outage%" or feedback_text like "%down%") then "urgent"
    else "Normal"
end as Feedback_Status
from feedback			-- it is only to show the result, we will add a seperate column belows
order by 2;				-- we can also write order by feedback_status as column is already created to see
						-- using select

alter table feedback
add column Feedback_Status varchar(10);

update feedback
set Feedback_status = 
case
	when (rating = 1) and (feedback_text like "%outage%" or feedback_text like "%down%") then "urgent"
    else "Normal"
end;
    
-- 10. Exercise: In billing, create a flag for each bill that is ‘Late’ if the payment_date is after the due_date, ‘On-Time’ if it’s the same, and ‘Early’ if before.

select *,
case
	when payment_date > due_date then "Late"
    when payment_date = due_date then "on-Time"
    when payment_date < due_date then "Early"
end as Flag
from billing;
