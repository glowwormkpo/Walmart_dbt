-- Grain: one row per store (current attributes as delivered in stores.csv).
with source as (

    select * from {{ source('walmart_raw', 'stores') }}

),

renamed as (

    select
        cast(store as integer)      as store_id,
        upper(trim(type))           as store_type,
        cast(size as integer)       as store_size_sqft
    from source

)

select * from renamed
