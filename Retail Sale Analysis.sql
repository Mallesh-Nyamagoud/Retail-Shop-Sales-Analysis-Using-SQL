 -- create database
create database Retail_Shop_Sales_Analysis;

-- create table with same columns as in data file
drop table if exists Sales;

create table Sales (
    transactions_id	int primary key,
	sale_date	date,
	sale_time	time,
	customer_id	int,
	gender	varchar(10),
	age	int,
	category	varchar(20),
	quantiy	 int,
	price_per_unit float,
	cogs	float,
	total_sale float
	);

-- describe created table structure
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'Sales';

-- data imported
select * from Sales;

-- Total Number of Rows
select count(*) as "Total Number Of Rows" from Sales;

-- Data Cleaning

-- check whether the columns contain null values
select * from Sales
where transactions_id is null
    or sale_date	is null
	or sale_time	is null
	or customer_id	is null
	or gender	is null
	or age	is null
	or category	is null
	or quantiy	is null 
	or price_per_unit is null
	or cogs	is null
	or total_sale is null;
      

-- Replace NULL with the average age for Age Column
 update Sales
	 set age = (select round( avg(age)) from Sales where age is not null)
     where age is null;


-- To maintain data integrity and ensure accurate calculations in reports and analysis
-- Delete rows where any of the columns (quantity, price, or total_amount) contain NULL values

delete from Sales 
	where quantiy	is null 
	or price_per_unit is null
	or cogs	is null
	or total_sale is null;


-- Data Exploration

-- How Many Records We Have?
select count(*) from Sales;

-- how many unique customers we have ?
select count(distinct(customer_id)) from Sales;

-- how many unique category we have ?
select count (distinct(category)) from Sales;

-- list the category we have
select distinct(category) from Sales;

-- how many years data we have ?
select distinct (extract(year from sale_date) ) from Sales;


-- Data Analysis / Business Key Problems

-- Write a SQL query to retrieve all columns for sales made on particular day like'2022-11-05:
 select * from sales
where sale_date = '2022-11-05';


--  Write a SQL query to retrieve all columns for sales made on particular month and year
select * from sales
where extract(month from sale_date) = 5 and extract (year from sale_date) = 2022;


SELECT *
FROM Sales
WHERE sale_date BETWEEN '2022-05-01' AND '2022-05-31';

-- total sales
select sum(total_sale) as total_sales from sales;

-- total quantity sold
select sum(quantiy) as total_quantity_sold from sales;

-- total unique customers
select count(distinct(customer_id)) as total_unique_customers from sales;


/* Write a SQL query to retrieve all transactions where the category is 'Clothing' and 
the quantity sold is more or equal to 4 in the month of Nov-2022: */

select * from sales
where category = 'Clothing' and quantiy >= 4 
	and extract(month from sale_date) = 11 and extract (year from sale_date) = 2022;


select * from sales
where category = 'Clothing' and quantiy >= 4 
and to_char(sale_date, 'mm - yyyy') = '11 - 2022';



-- Write a SQL query to calculate the total sales (total_sale) and total_quantity_sold for each category.
select category, sum(quantiy) as total_quantity_sold , sum(total_sale) as net_sale
from Sales 
group by category
order by net_sale desc;


/* Write a SQL query to find the average age of customers who purchased 
items from the 'Beauty' category. */
select avg(age) as average_age from sales
where category = 'Beauty';


/* Age Distribution Analysis: */

select min(age) from sales;

select max(age) from sales;


with age_group as (
select transactions_id,case 
           when age between 15 and 25 then '18-25 Age Group'
           when age between 25 and 35 then '25-35 Age Group'
           when age between 35 and 45 then '35-45 Age Group'
           when age between 45 and 55 then '45-55 Age Group'
           when age between 55 and 65 then '55-65 Age Group'
          else 'invalid'
end as Age_Group from Sales )
select age_group , 
count(distinct(customer_id)) as "Total Unique Customers",
count(s.transactions_id) as "Total Transactions" , 
sum(s.quantiy) as "Total Quantity Sold",
sum(total_sale) as "Net Sales Amount"
from Sales as s join age_group as a on s.transactions_id = a.transactions_id
group by Age_Group;



-- Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from sales 
where total_sale > 1000;

-- Analysis of Top 10 Customers 
select customer_id, count(transactions_id) as "Total_Transactions_Count", 
                 	sum(quantiy) as  "Total_Quantity_Purchased " ,  
                   sum(total_sale) as "Total_Sales_Revenue_by_Customer"
from sales
group by customer_id
order by sum(total_sale) desc
limit 10;


-- Customer Purchase Insights by Gender and Category
select gender, category,count(transactions_id) as "Total_Transactions_Count", 
                 	sum(quantiy) as  "Total_Quantity_Purchased " ,  
                   sum(total_sale) as "Total_Sales_Revenue_by_Customer"
from sales
group by gender,category
order by sum(total_sale) desc;


/* Write a SQL query to calculate the average sale for each month. 
Find out best selling month in each year: */
SELECT year,month,avg_sale
FROM 
(    SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM sales
GROUP BY 1, 2
) as t1
WHERE rank = 1


-- Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, COUNT(DISTINCT(customer_id)) as unique_customers
FROM sales
GROUP BY category;


-- Time-Based Sales Performance Overview

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM sales
)
SELECT 
    shift,
    COUNT(*) as total_orders , 
	sum(total_sale) as net_sale
FROM hourly_sale
GROUP BY shift;


-- profit analysis
with profit_analysis as (
	select * , (total_sale - (quantiy * cogs )) as profit
	from sales
)
select extract(year from sale_date) as year ,category, 
	sum(quantiy) as "total_quantity_sold",
    sum(total_sale) as "net_sale",
    round(sum(profit)) as "net profit" from profit_analysis
	group by year , category;

-- End of Project
