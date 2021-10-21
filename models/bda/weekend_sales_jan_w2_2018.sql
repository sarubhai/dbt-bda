-- Weekend Sales for Top 10 Car Brands for 2nd Week on Jan 2018

{{ config(materialized='table') }}

with weekend_sales_jan_w2_2018 as (
    SELECT 
    product.make as brand, round(sum(sales.amount - sales.discount)/1000, 0) || ' K USD' as sales_amount
    FROM car.sales sales
    INNER JOIN car.product product
    ON sales.product_id = product.id
    INNER JOIN car.dates dates
    ON sales.txn_date = dates.day_date
    WHERE dates.year_number = 2018 
    AND dates.month_name = 'January'
    AND dates.week_of_month_number = 4
    AND dates.day_name IN ('Saturday', 'Sunday')
    GROUP BY product.make
    ORDER BY sales_amount DESC
    LIMIT 10
)

select *
from weekend_sales_jan_w2_2018
