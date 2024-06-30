use sql_assignment_2;

select * from customers;
select * from orders;
select * from items;

select distinct customer_id from customers;
select distinct order_id from orders;
select distinct item_id from items;

alter table customers
add primary key (customer_id);

alter table orders
add primary key (order_id);

alter table items
add primary key (item_id);


-- [Question 1] find out top 5 customers with the most orders

select customer_id, count(customer_id) as No_of_Orders
from orders
group by customer_id
order by No_of_Orders desc, customer_id
limit 5;

-- if we want customers name or more detail is required we can do it with join as well

select c.customer_id, c.first_name, c.last_name, count(o.customer_id) as No_of_Orders
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id
order by No_of_orders desc, customer_id
limit 5;

-- [Question 2] find out the top 3 most sold items

select i.item_id, i.item_name, i.item_type, count(o.item_id) No_of_items_Sold
from items i
join orders o
on i.item_id = o.item_id
group by i.item_id
order by No_of_items_Sold desc
limit 3;

-- [Question 3] show customers and total order only for customers with more than 4 orders

select c.customer_id, c.first_name, c.last_name, count(o.customer_id) as Total_Orders
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id
having Total_Orders > 4
order by Total_Orders desc;


-- [Question 4] only show records for customers that live on oak st, pine st or cedar st and 
-- belong to either anyville or anycity

select *
from customers
where (address like '%oak st%' or address like '%pine st%' or address like '%cedar st%')
and city in ('Anyville' , 'Anycity')
order by city;

-- [Question 5] In a simple select query, create a column called price_label in which label each item's price as:
-- low price if its price is below 10
-- moderate price if its price is between 10 and 50
-- high price if its price is above 50
-- "unavailable" in all other cases

select item_id, item_name, item_type, item_price,
case
	when item_price < 10 then 'Low Price'
    when item_price between 10 and 50 then 'Moderate Price'
    when item_price > 50 then 'High Price'
    else 'Unavailable'
end as Price_Label
from items;

-- order this query by price in descending order

select item_id, item_name, item_type, item_price,
case
	when item_price < 10 then 'Low Price'
    when item_price between 10 and 50 then 'Moderate Price'
    when item_price > 50 then 'High Price'
    else 'Unavailable'
end as Price_Label
from items
order by item_price desc;

-- [Question 6] Using DDL commands, add a column called stock_level to the items table.

alter table items
add column Stock_Level varchar(50); 

-- [Question 7] Update this column in the following way:
-- low stock if the amount is below 20
-- moderate stock if the amount is between 20 and 50
-- high stock if the amount is over 50

set sql_safe_updates = 0;

update items
set Stock_Level = 
case
	when amount_in_stock < 20 then 'Low Stock'
    when amount_in_stock between 20 and 50 then 'Moderate Stock'
    when amount_in_stock > 50 then 'High Stock'
end;

select * from items;

-- [Question 8] from the customers table, delete the column country

alter table customers
drop column country;

select * from customers;

-- [Question 9] find out the total no of customers in anytown without using group by and having

select count(city) as Customers_in_Anytown
from customers
where city = 'Anytown';

-- [Question 10] use DDL commands to add a column to the customers table called street. add this column directly
-- after the address column
-- hint: google how to add a column before/after another column in MySQL 

alter table customers
add street varchar (10) AFTER address;

select * from customers;

-- [Question 11] update this column by extracting the street name from address
-- (hint: MySQL also has mid/left/right functions the same as excel. You can first test these with SELECT before using UPDATE)

select address, substr(address,4)
from customers;

update customers
set street = substr(address,4);

select * from customers;

-- [Question 12] Find out the number of customers per city per street. 
-- order the results in ascending order by city and then descending order by street

select distinct street from customers;
select distinct city from customers;

select city, street, count(customer_id) as Customers_Per_Street
from customers
group by city, street
order by city, street;

-- [Question 13] in the orders table, update shipping date and order date to the correct format. 
-- also change the data types of these columns to date. 
-- (try to change both columns in one update statement and one alter statement) 

select * from orders;

update orders
set order_date = str_to_date(order_date, '%d/%m/%Y'),
shipping_date = str_to_date(shipping_date, '%d/%m/%Y');

alter table orders
modify order_date date, 
modify shipping_date date;

-- [Question 14] write a query to get order id, order date, shipping date and difference in days 
-- between order date and shipping date for each order
-- (google which function in MySQL can help you do this)
-- what do you observe in the results?

select order_id, order_date, shipping_date, 
DATEDIFF(shipping_date, order_date) AS Date_Diff_in_Days -- w3schools says the interval is also required before two
from orders;											 -- dates but it gives error here for year, month or day


-- [Question 15] find out items priced higher than the avg price of all items 
-- (hint: you will need to use a subquery here)

select avg(item_price)
from items;

select item_name, item_type, item_price
from items
where item_price > (select avg(item_price) from items);

-- [Question 16] using inner joins, get customer_id, first_name, last_name, order_id, order_date, item_id, 
-- item_name and item_price
-- (hint: you will need to join all three tables)

select c.customer_id, c.first_name, c.last_name, o.order_id, o.order_date, i.item_id, i.item_name, i.item_price
from customers c
join orders o on c.customer_id = o.customer_id
join items i on o.item_id = i.item_id;

