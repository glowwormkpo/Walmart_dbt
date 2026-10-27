-- Grain: one row per store, department and week.
with source as (

    select * from {{ source('walmart_raw', 'department') }}

),

renamed as (

    select
        cast(store as integer)              as store_id,
        cast(dept as integer)               as dept_id,
        cast(date as date)                  as week_date,
        {{ date_to_id('date') }}            as date_id,
        cast(weekly_sales as numeric(18, 2)) as weekly_sales,
        cast(isholiday as boolean)          as is_holiday_week
    from source

)

select * from renamed
