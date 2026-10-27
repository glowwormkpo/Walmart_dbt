-- Dashboard reports 2, 5 and 9: sales by year / month, by store type and month,
-- and each store type's share of sales.
-- Grain: one row per month and store type.
with sales as (

    select * from {{ ref('fct_weekly_department_sales') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

stores as (

    select * from {{ ref('dim_store') }}

),

monthly as (

    select
        dates.month_start_date,
        dates.calendar_year,
        dates.calendar_month,
        stores.store_type,
        sum(sales.weekly_sales)             as total_sales,
        count(distinct sales.store_id)      as stores_reporting,
        count(distinct sales.week_date)     as weeks_in_month
    from sales
    inner join dates  on sales.date_id  = dates.date_id
    inner join stores on sales.store_sk = stores.store_sk
    group by 1, 2, 3, 4

)

select
    month_start_date,
    calendar_year,
    calendar_month,
    store_type,
    round(total_sales, 2)                                                   as total_sales,
    stores_reporting,
    weeks_in_month,
    round(total_sales / nullif(stores_reporting * weeks_in_month, 0), 2)    as avg_weekly_sales_per_store,
    round(100.0 * total_sales
        / sum(total_sales) over (partition by month_start_date), 2)         as pct_of_month_sales
from monthly
