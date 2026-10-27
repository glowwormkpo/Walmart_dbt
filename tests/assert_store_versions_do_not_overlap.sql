-- SCD2 integrity: each store has exactly one current version, and no two versions of the
-- same store cover the same moment (otherwise a point-in-time join would duplicate sales).
with versions as (

    select
        store_id,
        store_sk,
        valid_from,
        valid_to,
        is_current,
        lead(valid_from) over (partition by store_id order by valid_from) as next_valid_from
    from {{ ref('dim_store') }}

),

overlapping_versions as (

    select store_id, 'overlapping versions' as issue
    from versions
    where next_valid_from is not null
      and next_valid_from < valid_to

),

current_counts as (

    select store_id, 'not exactly one current version' as issue
    from versions
    group by store_id
    having sum(case when is_current then 1 else 0 end) <> 1

)

select * from overlapping_versions
union all
select * from current_counts
