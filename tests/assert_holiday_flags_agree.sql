{{ config(severity = 'warn') }}

-- Source audit: department.csv and fact.csv each carry their own IsHoliday flag, and both
-- should match the published holiday calendar. Warns (doesn't fail the build) on any week
-- where the files disagree with each other or with the calendar.
with dept_flags as (

    select week_date, max(case when is_holiday_week then 1 else 0 end) as dept_flag
    from {{ ref('stg_walmart__department_sales') }}
    group by week_date

),

fact_flags as (

    select week_date, max(case when is_holiday_week then 1 else 0 end) as fact_flag
    from {{ ref('stg_walmart__store_conditions') }}
    group by week_date

),

calendar as (

    select holiday_week_date as week_date, 1 as calendar_flag
    from {{ ref('walmart_holiday_calendar') }}

),

weeks as (

    select week_date from dept_flags
    union
    select week_date from fact_flags

)

select
    weeks.week_date,
    dept_flags.dept_flag,
    fact_flags.fact_flag,
    coalesce(calendar.calendar_flag, 0) as calendar_flag
from weeks
left join dept_flags on weeks.week_date = dept_flags.week_date
left join fact_flags on weeks.week_date = fact_flags.week_date
left join calendar   on weeks.week_date = calendar.week_date
where coalesce(dept_flags.dept_flag, fact_flags.fact_flag) <> coalesce(fact_flags.fact_flag, dept_flags.dept_flag)
   or coalesce(dept_flags.dept_flag, fact_flags.fact_flag) <> coalesce(calendar.calendar_flag, 0)
