{{
    config(
        materialized = 'incremental',
        unique_key = ['store_id', 'dept_id', 'date_id'],
        on_schema_change = 'append_new_columns'
    )
}}

-- Grain: one row per store, department and week.
-- Incremental: after the first full build, each run only re-processes the trailing
-- `incremental_lookback_weeks` weeks and merges them on the grain key, so new weeks are
-- added and late corrections to recent weeks overwrite the old values without duplicates.
with sales as (

    select * from {{ ref('stg_walmart__department_sales') }}

    {% if is_incremental() %}
    where week_date >= (
        select {{ dbt.dateadd('week', -1 * var('incremental_lookback_weeks'), 'max(week_date)') }}
        from {{ this }}
    )
    {% endif %}

),

stores as (

    select * from {{ ref('dim_store') }}

)

select
    sales.store_id,
    sales.dept_id,
    sales.date_id,
    stores.store_sk,
    sales.week_date,
    sales.weekly_sales,
    sales.is_holiday_week,
    current_timestamp                                   as dbt_loaded_at
from sales
-- Point-in-time join: the store version that was in effect during that sales week.
left join stores
    on  sales.store_id = stores.store_id
    and cast(sales.week_date as timestamp) >= stores.valid_from
    and cast(sales.week_date as timestamp) <  stores.valid_to
