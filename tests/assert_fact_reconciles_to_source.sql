-- The department sales fact must have exactly the same row count and total sales as the
-- raw department.csv table: nothing dropped by a join, nothing duplicated by a fan-out.
-- Returns a row (fails) on any difference.
with source_totals as (

    select count(*) as row_count, round(sum(weekly_sales), 2) as total_sales
    from {{ source('walmart_raw', 'department') }}

),

fact_totals as (

    select count(*) as row_count, round(sum(weekly_sales), 2) as total_sales
    from {{ ref('fct_weekly_department_sales') }}

)

select
    source_totals.row_count     as source_rows,
    fact_totals.row_count       as fact_rows,
    source_totals.total_sales   as source_sales,
    fact_totals.total_sales     as fact_sales
from source_totals
cross join fact_totals
where source_totals.row_count <> fact_totals.row_count
   or abs(source_totals.total_sales - fact_totals.total_sales) > 0.01
