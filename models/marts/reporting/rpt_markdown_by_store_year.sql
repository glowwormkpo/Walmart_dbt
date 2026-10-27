-- Dashboard report 4: promotional markdowns by store and year.
-- Grain: one row per store and year.
--
-- Built from store-week rows, NOT department rows. The original Streamlit report summed
-- MARKDOWN1 + ... + MARKDOWN5 across the department-grain fact table, which
--   (a) counted each store-week markdown once per department, and
--   (b) returned null for any week where one of the five columns was null,
--       because adding a null in SQL gives null.
-- Here markdowns are summed once per store-week with nulls treated as zero, and only
-- weeks that have markdown data count toward the ratio.
with store_weeks as (

    select * from {{ ref('fct_weekly_store_conditions') }}

),

sales as (

    select * from {{ ref('int_store_weekly_sales') }}

),

joined as (

    select
        store_weeks.store_id,
        extract(year from store_weeks.week_date)    as calendar_year,
        store_weeks.total_markdown,
        store_weeks.has_markdown_data,
        sales.weekly_sales
    from store_weeks
    left join sales
        on  store_weeks.store_id = sales.store_id
        and store_weeks.date_id  = sales.date_id

)

select
    store_id,
    calendar_year,
    round(sum(total_markdown), 2)                                               as total_markdown,
    sum(case when has_markdown_data then 1 else 0 end)                          as weeks_with_markdown_data,
    round(sum(case when has_markdown_data then weekly_sales end), 2)            as sales_in_markdown_weeks,
    round(100.0 * sum(total_markdown)
        / nullif(sum(case when has_markdown_data then weekly_sales end), 0), 2) as markdown_pct_of_sales
from joined
group by store_id, calendar_year
