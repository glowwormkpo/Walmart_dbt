-- Dashboard report 1: department-wise sales.
-- Grain: one row per department.
with sales as (

    select * from {{ ref('fct_weekly_department_sales') }}

),

by_department as (

    select
        dept_id,
        sum(weekly_sales)                   as total_sales,
        avg(weekly_sales)                   as avg_weekly_sales_per_store,
        count(distinct store_id)            as stores_carrying,
        count(distinct week_date)           as weeks_with_sales
    from sales
    group by dept_id

)

select
    dept_id,
    round(total_sales, 2)                                               as total_sales,
    round(avg_weekly_sales_per_store, 2)                                as avg_weekly_sales_per_store,
    stores_carrying,
    weeks_with_sales,
    round(100.0 * total_sales / sum(total_sales) over (), 3)            as pct_of_total_sales,
    rank() over (order by total_sales desc)                             as sales_rank
from by_department
