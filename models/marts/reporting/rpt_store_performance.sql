-- Dashboard reports 6 and 7: sales by store size, and holiday vs. regular weeks by store.
-- Grain: one row per store (current attributes).
with store_weeks as (

    select * from {{ ref('int_store_weekly_sales') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

stores as (

    select * from {{ ref('dim_store') }} where is_current

),

by_store as (

    select
        store_weeks.store_id,
        sum(store_weeks.weekly_sales)                                               as total_sales,
        avg(store_weeks.weekly_sales)                                               as avg_weekly_sales,
        avg(case when dates.is_holiday_week then store_weeks.weekly_sales end)      as avg_holiday_week_sales,
        avg(case when not dates.is_holiday_week then store_weeks.weekly_sales end)  as avg_regular_week_sales,
        count(*)                                                                    as weeks_reporting
    from store_weeks
    inner join dates on store_weeks.date_id = dates.date_id
    group by store_weeks.store_id

)

select
    by_store.store_id,
    stores.store_type,
    stores.store_size_sqft,
    round(by_store.total_sales, 2)                                          as total_sales,
    round(by_store.avg_weekly_sales, 2)                                     as avg_weekly_sales,
    round(by_store.avg_weekly_sales / nullif(stores.store_size_sqft, 0), 4) as avg_weekly_sales_per_sqft,
    round(by_store.avg_holiday_week_sales, 2)                               as avg_holiday_week_sales,
    round(by_store.avg_regular_week_sales, 2)                               as avg_regular_week_sales,
    round(100.0 * (by_store.avg_holiday_week_sales / nullif(by_store.avg_regular_week_sales, 0) - 1), 2)
                                                                            as holiday_lift_pct,
    by_store.weeks_reporting,
    rank() over (order by by_store.total_sales desc)                        as sales_rank
from by_store
inner join stores on by_store.store_id = stores.store_id
