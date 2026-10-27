-- Grain: one row per week-ending date.
with weeks as (

    select * from {{ ref('int_calendar_weeks') }}

),

holidays as (

    select * from {{ ref('walmart_holiday_calendar') }}

)

select
    {{ date_to_id('weeks.week_date') }}                     as date_id,
    weeks.week_date,
    extract(year from weeks.week_date)                      as calendar_year,
    extract(quarter from weeks.week_date)                   as calendar_quarter,
    extract(month from weeks.week_date)                     as calendar_month,
    {{ dbt.date_trunc('month', 'weeks.week_date') }}        as month_start_date,
    extract(week from weeks.week_date)                      as week_of_year,
    weeks.is_holiday_week,
    holidays.holiday_name
from weeks
left join holidays
    on weeks.week_date = holidays.holiday_week_date
