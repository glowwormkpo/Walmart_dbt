-- Grain: one row per store version (SCD Type 2).
--
-- The snapshot stamps the first version with the time it was first captured, but the sales
-- history goes back to 2010. Left as-is, a point-in-time join would match no historical
-- sales. So each store's FIRST version is treated as valid from the beginning of time;
-- later versions keep the real change timestamp. Sales then join to the version that was
-- in effect that week, and history stays correct after a store is resized or retyped.
with snapshot as (

    select * from {{ ref('snap_walmart__stores') }}

),

versions as (

    select
        dbt_scd_id                                                          as store_sk,
        store_id,
        store_type,
        store_size_sqft,
        row_number() over (partition by store_id order by dbt_valid_from)   as version_number,
        dbt_valid_from,
        dbt_valid_to
    from snapshot

)

select
    store_sk,
    store_id,
    store_type,
    store_size_sqft,
    version_number,
    case
        when version_number = 1 then cast('1900-01-01' as timestamp)
        else dbt_valid_from
    end                                                     as valid_from,
    dbt_valid_to                                            as valid_to,
    dbt_valid_to = cast('9999-12-31' as timestamp)          as is_current
from versions
