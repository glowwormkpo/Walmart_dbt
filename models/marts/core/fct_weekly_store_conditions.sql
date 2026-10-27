-- Grain: one row per store and week (fact.csv grain).
-- Store-level measures live in their own fact so they are never repeated per department.
-- Covers weeks after the last sales week too (fact.csv runs to Jul 2013).
with conditions as (

    select * from {{ ref('stg_walmart__store_conditions') }}

),

stores as (

    select * from {{ ref('dim_store') }}

)

select
    conditions.store_id,
    conditions.date_id,
    stores.store_sk,
    conditions.week_date,
    conditions.is_holiday_week,
    conditions.temperature_f,
    conditions.fuel_price,
    conditions.cpi,
    conditions.unemployment_rate,
    conditions.markdown_1,
    conditions.markdown_2,
    conditions.markdown_3,
    conditions.markdown_4,
    conditions.markdown_5,
    conditions.total_markdown,
    conditions.has_markdown_data
from conditions
left join stores
    on  conditions.store_id = stores.store_id
    and cast(conditions.week_date as timestamp) >= stores.valid_from
    and cast(conditions.week_date as timestamp) <  stores.valid_to
