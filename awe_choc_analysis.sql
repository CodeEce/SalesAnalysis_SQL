-- ---------Begginner Level -------------------------------------------------------------------------------------------------------------------
-- 1.List all unique product categories from the products table.
select distinct(category) from products;

-- 2.Display all details of sales that occurred after 2021-05-01.
select * from sales where SaleDate > '2021-05-01';

-- 3.Print details of shipments (sales) where amounts are > 2,000 and boxes are < 100.
select * from sales where amount > 2000 and boxes < 100;

-- 4.List all products with their sizes and costs per box where the cost exceeds 5.
select product, size, cost_per_box from products where cost_per_box > 5;

-- 5.Find the names of all salespeople (Salesperson) and their corresponding teams.
select salesperson, team from people;

-- 6.Display all sales details where more than 1000 boxes were sold.
select * from sales where boxes > 1000;

-- Medium Level --------------------------------------------------------------------------------------------------------------
-- 7.Retrieve the total number of customers served by each region (GeoID).
select geo.geoid, Region, sum(sales.Customers) as total_customer 
from geo join sales on geo.geoid = sales.geoid group by geoid order by geoid;

-- 8.Find the total number of sales made by each salesperson (SPID).
select spid as Person_id, sum(amount) as total_sales from sales group by SPID;

-- 9.How many shipments (sales) did each salesperson have in January 2022?
select count(*), salesperson from sales join people on sales.spid = people.spid 
where SaleDate between '2022-1-1' and '2022-1-31' group by Salesperson;

-- 10.Get the names of salespeople (Salesperson) and the regions they sold in, ensuring no duplicates.
select distinct(salesperson), region from people join sales on sales.SPID = people.SPID 
join geo on geo.GeoID = sales.GeoID order by Salesperson;

-- 11.Which product sells more boxes? Milk Bars or Eclairs?
select product, sum(boxes) as box_count from sales join products on sales.pid = products.PID
 where Product in('Milk Bars', 'Eclairs') group by Product;

-- 12.What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
select distinct(salesperson) from people join sales on people.SPID = sales.spid 
where saledate between '2022-01-01' and '2022-01-07';

-- 13.Which salespersons did not make any shipments in the first 7 days of January 2022?
select p.salesperson from people as p where p.spid not in (select distinct sales.spid from sales 
where sales.saledate between '2022-01-01' and '2022-01-07');

-- 14.How many times did we ship more than 1,000 boxes in each month?
select count(*) as Times_we_shipped_1k, year(saledate) as Year, month(saledate) as Month
 from sales where Boxes > 1000 group by Year, Month;

-- 15.Find the total amount of sales (Amount) and the total number of boxes sold for each GeoID.
select GeoID, sum(amount) as total_sale_Amount, sum(boxes) as total_noof_box from sales group by geoid;

-- 16.India or Australia? Who buys more chocolate boxes on a monthly basis?
 select year(saledate) as Year, month(saledate) as Month,
 sum(CASE WHEN g.geo = 'India' THEN boxes ELSE 0 END) as 'India Boxes', 
 sum(CASE WHEN g.geo = 'Australia' THEN boxes ELSE 0 END) as 'Australia Boxes' 
 from sales s join geo g on g.GeoID = s.GeoID 
 group by year(saledate), month(saledate) order by year(saledate), month(saledate);

-- Hard Level ---------------------------------------------------------------------------------------------------
-- 17.Identify the salesperson who made the highest total sales (Amount).
select salesperson, sum(amount) as total_sale_amount from people as p join sales as s on p.spid = s.SPID 
group by Salesperson order by total_sale_amount desc limit 1;

-- 18.Find the product (Product) that generated the highest revenue (Amount) and its total revenue.
select product, sum(amount) as revenue from products p join sales s on p.pid = s.pid 
group by product order by revenue desc limit 1;

-- 19.Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?
select *, case when weekday(saledate) = 2 then 'Wednesday Shipment' else '' end as 'W Shipment' 
from sales where customers < 100 and boxes < 100;

-- 20.Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
select product, sum(boxes) as total_box from sales join products on products.pid = sales.pid 
where saledate between '2022-02-01' and '2022-02-07' and product in ('Milk Bars', 'Eclairs') group by Product;

-- 21.List the total revenue (Amount) generated by each product category (Category).
select Category, sum(amount) as total_revenue from sales as s join products as p on s.PID = p.PID 
group by Category order by total_revenue desc;

-- 22.Display the region (Region) with the highest number of customers served.
select g.region, sum(Customers) as total_customer from geo as g join sales as s on g.GeoID = s.GeoID 
group by region order by total_customer desc limit 1;

-- 23.Calculate the average cost per box of products sold in each category (Category).
select p.category, round(avg(Cost_per_box * boxes), 2) as avg_cost_per_box 
from products as p join sales as s on p.pid = s.pid group by p.Category;

-- 24.Identify the salesperson and product combination that had the highest number of boxes sold in a single sale.
select salesperson, product, boxes from products as p join sales as s on p.pid = s.pid 
join people as pe on pe.SPID = s.spid order by boxes desc limit 1;

-- 25.Did we ship at least one box of 'After Nines' to 'New Zealand' on all the months?
select year(saledate) as Year, month(saledate) as Month, if(sum(s.boxes) > 1, 'Yes', 'No') as Status 
from geo as g left join sales as s on g.GeoID = s.geoid join products as p where g.geo = 'New Zealand' and p.product = 'After Nines' 
group by year(saledate), month(saledate) order by Year, Month;

-- Advanced Concept --------------------------------------------------------

-- 26.	Identify the regions (Region) where sales (Amount) are missing (NULL) and calculate the total number of such entries for each region.
select region,
(select count(*) from sales as s where amount is null and  s.geoid = g.geoid) as TotalMissingSales
 from geo as g;

-- 27.	Use a window function to calculate the cumulative total sales (Amount) for each salesperson (Salesperson) over time, ordered by SaleDate.
select Salesperson,SaleDate, amount, sum(s.Amount) over (partition by p.Salesperson order by SaleDate) as Cumulative_SaleTotal
from sales as s join people as p on s.SPID = p.SPID order by SaleDate;

-- 28.	Create a view named CategoryPerformance that displays the total sales (Amount), average sales, 
-- and total customers (Customers) for each product category (Category). Query this view to retrieve categories with average sales exceeding 5,800.
 create view CategoryPerformance as 
 select Category,sum(amount) as total_sale,round(avg(amount),2) as avg_sale,sum(customers) as total_customer
 from sales as s left join products as p  on s.PID=p.PID group by p.category;

select category,avg_sale from CategoryPerformance where avg_sale>5800;

-- 29.	Write a query using a subquery to find the salespeople (SPID) whose total sales (Amount) are above the overall average sales of all salespeople.

SELECT SPID,sum(amount) as total_sale
FROM Sales
GROUP BY SPID
HAVING SUM(Amount) > (
    SELECT AVG(total_sales)
    FROM (
        SELECT SPID, SUM(Amount) AS total_sales
        FROM Sales
        GROUP BY SPID
    ) AS sales_summary
); 

-- 30.	Create a compound index on the sales table for faster lookups by GeoID and SaleDate.
--  Use this index to retrieve sales data grouped by GeoID and ordered by SaleDate.
create index idx_geoid_saledate on sales (geoid(20),SaleDate);
select geoid,saledate,sum(amount) as total_sale from sales group by geoid,SaleDate order by geoid,saledate;

-- 31.	Identify salespeople (Salesperson) who are not part of any team (Team IS NULL) and calculate their total sales (Amount) using subquery.
select s.spid,p.salesperson,sum(s.amount) as total_sale from sales s join people p on s.SPID=p.SPID where s.spid in (
select spid from people where team ='' )
group by spid;





