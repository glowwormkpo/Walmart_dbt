-- Dashboard reports 3, 8 and 10: weekly sales vs. CPI, vs. temperature, and fuel price by year.
-- Grain: one row per week that has sales.
-- Averages are taken across stores at the store-week grain, so every store counts once per
-- week no matter how many departments it has.
with store_weeks as (

    select * from {{ ref('int_store_weekly_sales') }}

),

dates as (

    select * from {{ ref('dim_date') }}

)

select
    dates.date_id,
    dates.week_date,
    dates.calendar_year,
    dates.is_holiday_week,
    dates.holiday_name,
    round(sum(store_weeks.weekly_sales), 2)         as total_sales,
    count(*)                                        as stores_reporting,
    round(avg(store_weeks.cpi), 3)                  as avg_cpi,
    round(avg(store_weeks.temperature_f), 2)        as avg_temperature_f,
    round(avg(store_weeks.fuel_price), 3)           as avg_fuel_price,
    round(avg(store_weeks.unemployment_rate), 3)    as avg_unemployment_rate,
    round(sum(store_weeks.total_markdown), 2)       as total_markdown
from store_weeks
inner join dates on store_weeks.date_id = dates.date_id
group by 1, 2, 3, 4, 5
