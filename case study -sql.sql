-- CASE STUDY - SQL 

-- Write a query to select all columns from the food_price table.
use casestudy;

select *
from food_price;


-- Write a query to show prices and currency against the category 'cereals and tubers'.

select price, currency, category
from food_price
where category = "cereals and tubers";

-- Write a query to select all records from the commodity table where the category is either 'food' or 'dairy'.
-- show two ways for it

select *
from commodity
where category = "food" or category = "dairy";

select *
from commodity
where category in ("food" , "dairy");


-- Write a query to select all commodities from the commodity table where the cmname includes the word 'Rice'.

select *
from commodity
where cmname like "rice%";
 
--  Write a query to show all entries from food_price against all cmname except 'flour'.

select *
from food_price
where cmname not like "%flour%";


-- Write a query to show all entries where the price is less than and equal to 15.
select *
from food_price
where price <= 15;


-- Write a query to show all entries where the price is greater than 20 but less than and equal to 50.

select *
from food_price
where price > 20 and price <= 50;


-- Write a query to show adm1id,city and province where the category is 'cereals and tubers' and the price is less than 15.

select adm1id, mktname, admname
from food_price
where category = "cereals and tubers" and price < 15;


-- Write a query to showt he food_price table ordered by provinces in ascending order and then show the price in descending order against each province.
select *
from food_price
order by admname asc, price desc;



-- show 20 enteries that has least price scale.alter

select *
from food_price
order by price asc
limit 20;


-- Write a query to insert a new record into the food_price table with the following 
-- details: date='2024-03-08', cmname='Rice (basmati) - Retail', unit='KG', 
-- category='cereals and tubers', price=20, currency='PKR', country='Pakistan', 
-- admname='Punjab', and assuming commodity_id for 'Rice (basmati) - Retail' is 102

set sql_safe_updates = 0;


insert into food_price (date , cmname, unit, category, price, currency, country, admname, cmid)
values("2024-03-08", "Rice (basmati)", "KG", "cereals and tubers", "20", "PKR", "Pakistan", "Punjab", "102");
 
select *
from food_price;


-- How do you make the id column in the food_price table auto-increment with each new record inserted?

alter table food_price
add column serial_id int auto_increment primary key;

select *
from food_price;

