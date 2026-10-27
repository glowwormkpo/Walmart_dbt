-- Grain: one row per store and week.
-- Rolls department sales up to the store-week grain FIRST, then joins store-level
-- conditions (markdowns, CPI, fuel, temperature) at that same grain. Joining store-level
-- values onto department rows and then summing would count each store's markdown once
-- per department, so every store-level metric is kept at the store-week grain.
with department_sales as (

    select * from {{ ref('stg_walmart__department_sales') }}

),

store_week_sales as (

    select
        store_id,
        week_date,
        sum(weekly_sales)           as weekly_sales,
        count(*)                    as departments_reporting
    from department_sales
    group by store_id, week_date

),

conditions as (

    select * from {{ ref('stg_walmart__store_conditions') }}

)

select
    store_week_sales.store_id,
    store_week_sales.week_date,
    {{ date_to_id('store_week_sales.week_date') }}   as date_id,
    store_week_sales.weekly_sales,
    store_week_sales.departments_reporting,
    conditions.total_markdown,
    conditions.has_markdown_data,
    conditions.temperature_f,
    conditions.fuel_price,
    conditions.cpi,
    conditions.unemployment_rate
from store_week_sales
left join conditions
    on  store_week_sales.store_id  = conditions.store_id
    and store_week_sales.week_date = conditions.week_date
