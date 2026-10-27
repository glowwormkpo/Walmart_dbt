-- Grain: one row per week-ending date found in either source.
-- department.csv stops in Oct 2012 but fact.csv runs to Jul 2013, so both are unioned.
-- The two files agree on IsHoliday wherever they overlap (checked by a singular test),
-- so taking "flagged in either file" is safe for weeks that appear in only one.
with all_weeks as (

    select week_date, is_holiday_week from {{ ref('stg_walmart__department_sales') }}
    union all
    select week_date, is_holiday_week from {{ ref('stg_walmart__store_conditions') }}

)

select
    week_date,
    max(case when is_holiday_week then 1 else 0 end) = 1 as is_holiday_week
from all_weeks
group by week_date
