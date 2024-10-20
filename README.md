# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named ` Retail_Shop_Sales_Analysis `.
- **Table Creation**: A table named `sales ` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE Retail_Shop_Sales_Analysis;

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
### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM sales;
SELECT COUNT(DISTINCT(customer_id)) FROM sales;
SELECT DISTINCT(category) FROM sales;


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
	or total_sale is null;```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

```    
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







```


## Findings

* Sales Performance by Month
* Top Selling Categories
* Customer Demographics
* Unique Customer Insights
* Time-Based Sales Analysis
* Profit Analysis
* Top Customers
* Average Sale Trends







## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author – Mallesh Nyamagoud

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**: https://www.linkedin.com/in/malleshreddy2580
- **Gmail** : malleshnyamagoud2580@gmail.com

Thank you for your support, and I look forward to connecting with you!

