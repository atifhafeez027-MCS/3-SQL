-- 1) Changing Data Types for Date Columns:
 
-- Back up customer data:

create table customer_backup select * from customer;
create table billing_backup select * from billing;

-- SQL safe updates off

set sql_safe_updates = 0;

-- Change Subscription_Date

select * from customer;

select subscription_date, cast(subscription_date as date)
from customer;

select subscription_date, cast("20040425" as date)
from customer;

select subscription_date as old_date, str_to_date(subscription_date, "%m/%d/%Y") as new_date
from customer;

update customer
set subscription_date = str_to_date(subscription_date, "%m/%d/%Y");

alter table customer
modify subscription_date date;

-- Change Date_of_Birth

update customer
set date_of_birth = str_to_date(date_of_birth, "%m/%d/%Y");

alter table customer
modify Date_of_Birth date;

-- Change last_interaction_date

select * from customer;
select * from customer_backup;

update customer
set last_interaction_date = str_to_date(last_interaction_date, "%c/%e/%Y");

alter table customer
modify last_interaction_date date;

-- 2) Setting Primary Keys and Autoincremental Values:

-- for customer table

alter table customer
add primary key (customer_id);

alter table customer
modify customer_id int auto_increment;

-- for billing table

alter table billing
add primary key (bill_id);

alter table billing
modify bill_id int auto_increment;

select * from customer;
select * from billing;

-- 3) INSERT Statements:

-- Insert new customer:

insert into customer(first_name,last_name)
values("Ätif", "Hafeez");

select * from customer;

-- Adding a new billing entry:
 
 insert into billing (amount_due, late_fee)
 values(10000, 565);
 
 select * from billing;
 
-- Inserting a customer with minimal details:

-- Adding billing with only the billing cycle specified


-- 4) UPDATE Statements:

-- Update last_interaction_date of customers with a subscription_date before 2023-01-01 set the date to 2023-05-05:

update customer
set last_interaction_date = "2023-05-05"
where subscription_date < "2023-01-01";


-- Update email for customer named "Anonymous":

update customer
set email = "unavalable"
where first_name = "Anonymous";

-- Increase late fee for overdue payments:

select * from billing;

delete from billing
where bill_id = 1001;

update billing
set due_date = str_to_date(due_date, "%m/%d/%Y");		-- not executed

alter table billing
modify due_date date;				-- not executed

update billing
set  payment_date = str_to_date(payment_date, "%m/%d/%Y");  -- not executed

alter table billing
modify payment_date date;			-- not executed

update billing
set late_fee = late_fee + 100
where payment_date > due_date;  -- Query not yet executed

-- Changing phone number for customer ID 10:

update customer
set phone_number = 1234567889098
where customer_id = 10;

select * from customer;

-- 5) DELETE Statements:

-- Delete customers without subscription or last interaction date:

delete from customer
where subscription_date is NULL or last_interaction_date is NULL;

-- Erase customers named "Anonymous":

delete from customer
where first_name = "Anonymous" or last_name = "Anonymous";

-- Deleting entries in the billing table with due date before 2022-01-01:

delete from billing
where due_date < "2022-01-01";  -- not executed

select * from billing;

-- 6) Data Cleaning:
-- Identify customers with phone numbers not starting with "555":

select * from customer
where Phone_number not like "555%";

-- Replace "Road" with "Rd." in address field:

select * from customer
where address like "%road%";

update customer
set address = replace(address, "Road", "Rd");

-- replace (string, substring to be replaced, replacement string)

-- Convert billing cycle to uppercase:

update billing
set billing_cycle = upper(billing_cycle);

-- Identify records with negative discounts applied

select * from billing
where discounts_applied <0;

-- Remove leading/trailing whitespaces from the name field

update customer
set first_name = trim(first_name); -- trim() removes empty spaces/ white spaces from start and end (leading and trailing) 

-- 7) Data Transformation:

-- Adding a month to all subscription dates:

select subscription_date as old_date, subscription_date + interval 1 month as new_date
from customer;

update customer
set subscription_date = subscription_date + interval 1 month;

-- Extracting the year from subscription dates:

select subscription_date as full_date, year(subscription_date) as year_only
from customer;

select extract(year from subscription_date) as Year_only
from customer;

-- Concatenating name and email fields:

select concat(first_name, " | ", email)
from customer;

