-- Weekend Sales for Top 5 Car Brands for Jan 2018

select *, 'W1' as week
from {{ ref('weekend_sales_jan_w1_2018') }}
UNION
select *, 'W2' as week
from {{ ref('weekend_sales_jan_w2_2018') }}
UNION
select *, 'W3' as week
from {{ ref('weekend_sales_jan_w3_2018') }}
UNION
select *, 'W4' as week
from {{ ref('weekend_sales_jan_w4_2018') }}
