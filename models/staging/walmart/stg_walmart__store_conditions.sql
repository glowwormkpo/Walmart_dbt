-- Grain: one row per store and week.
-- Markdowns are only populated from Nov 2011 onward; a null markdown means "no data",
-- so the raw columns stay null and total_markdown treats them as zero for summing.
with source as (

    select * from {{ source('walmart_raw', 'fact') }}

),

renamed as (

    select
        cast(store as integer)                as store_id,
        cast(date as date)                    as week_date,
        {{ date_to_id('date') }}              as date_id,
        cast(temperature as numeric(6, 2))    as temperature_f,
        cast(fuel_price as numeric(6, 3))     as fuel_price,
        cast(markdown1 as numeric(18, 2))     as markdown_1,
        cast(markdown2 as numeric(18, 2))     as markdown_2,
        cast(markdown3 as numeric(18, 2))     as markdown_3,
        cast(markdown4 as numeric(18, 2))     as markdown_4,
        cast(markdown5 as numeric(18, 2))     as markdown_5,
        cast(cpi as numeric(12, 6))           as cpi,
        cast(unemployment as numeric(6, 3))   as unemployment_rate,
        cast(isholiday as boolean)            as is_holiday_week
    from source

),

final as (

    select
        *,
        coalesce(markdown_1, 0) + coalesce(markdown_2, 0) + coalesce(markdown_3, 0)
            + coalesce(markdown_4, 0) + coalesce(markdown_5, 0)     as total_markdown,
        (markdown_1 is not null or markdown_2 is not null or markdown_3 is not null
            or markdown_4 is not null or markdown_5 is not null)    as has_markdown_data
    from renamed

)

select * from final
