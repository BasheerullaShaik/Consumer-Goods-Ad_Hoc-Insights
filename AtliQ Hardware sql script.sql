--*1.Market Presence of AtliQ Exclusive in the APAC Region*/
select distinct market
from dim_customer
where customer='Atliq Exclusive' and region='APAC';

--*2.Unique Product Counts by Segment: Ranked by Highest to Lowest*/
SELECT 
    segment, COUNT(DISTINCT product_code) AS product_count
FROM
    dim_product
GROUP BY segment
ORDER BY product_count DESC

--*3.The percentage increase in unique products from 2021 to 2022*/
with cte1 as (
select 
count(distinct(case when fiscal_year=2020 then product_code end)) as unique_products_2020,
count(distinct(case when fiscal_year=2021 then  product_code end)) as unique_products_2021
from fact_sales_monthly
)
select *,
round((unique_products_2021-unique_products_2020)/unique_products_2020*100,2) as percentage_change
from cte1 

--*4.Here’s a report detailing the top 5 customers with the highest
--average pre-invoice discount percentage for the fiscal year 2021 in the Indian market.*/
SELECT 
    customer_code,
    customer,
    ROUND(AVG(pre_invoice_discount_pct) * 100, 2) AS average_discount_percentage
FROM
    dim_customer
        JOIN
    fact_pre_invoice_deductions USING (customer_code)
WHERE
    fiscal_year = 2021 AND market = 'India'
GROUP BY customer_code
ORDER BY average_discount_percentage DESC
LIMIT 5

--*5.Top-Performing Channel for Gross Sales in FY 2021 and Its Contribution Percentage*/
with cte1 as (
select c.channel,
      sum(gp.gross_price*sm.sold_quantity) as total_sales
from fact_gross_price gp
join fact_sales_monthly sm
on sm.product_code=gp.product_code
join dim_customer c
on c.customer_code=sm.customer_code
where sm.fiscal_year=2021
group by c.channel
order by total_sales desc
)
select channel,
       concat(round(total_sales/1000000,2),' ','M') as gross_sales_in_millions,
       concat(round(total_sales/(sum(total_sales) over() ) * 100,2),' ','%') as percentage
from cte1

--*6.Products with Highest and Lowest Manufacturing Costs*/
SELECT 
    product, product_code, manufacturing_cost
FROM
    dim_product p
        JOIN
    fact_manufacturing_cost mc USING (product_code)
WHERE
    manufacturing_cost = (SELECT 
            MAX(manufacturing_cost)
        FROM
            fact_manufacturing_cost)
        OR manufacturing_cost = (SELECT 
            MIN(manufacturing_cost)
        FROM
            fact_manufacturing_cost)
ORDER BY manufacturing_cost DESC

--*7.Top 3 Products by Total Sold Quantity in Each Division for FY 2021*/
with cte1 as (
select 
division,
product_code,
product,
sum(sold_quantity)  as total_sold_qty from dim_product
join fact_sales_monthly sm
using(product_code)
where fiscal_year=2021
group by division,product_code,product
order by division 
),
cte2 as (
select 
division,
product_code,
product,
total_sold_qty,
dense_rank() over(partition by division order by total_sold_qty desc) as rank_order
from cte1
)
select * from cte2
where rank_order<=3













