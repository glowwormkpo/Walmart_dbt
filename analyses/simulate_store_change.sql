-- Demo: watch the SCD Type 2 snapshot capture a change.
-- The CSVs are a single static snapshot, so nothing ever changes on its own.
-- Run the commented statements in a Snowflake worksheet (not through dbt):
--
--   1. dbt build                                  -- first run: every store has version 1
--   2. Note store 1's current size, then run the UPDATE below to fake a remodel
--   3. dbt build                                  -- snapshot closes v1 and opens v2
--   4. Run the check query                        -- store 1 now has 2 versions
--   5. Put the original size back with the RESTORE statement
--      (the next build gives store 1 a 3rd version, back at the original size)

-- 2. Note the current value, then fake a remodel
-- SELECT STORE, TYPE, SIZE FROM WALMART_E2E.RAW.STORES WHERE STORE = 1;
-- UPDATE WALMART_E2E.RAW.STORES SET SIZE = 175000 WHERE STORE = 1;

-- 4. Check the history
select store_id, version_number, store_type, store_size_sqft, valid_from, valid_to, is_current
from {{ ref('dim_store') }}
where store_id = 1
order by version_number;

-- Historical sales still point at version 1 (the size in effect when they happened):
-- select d.version_number, count(*) as sales_rows
-- from {{ ref('fct_weekly_department_sales') }} s
-- join {{ ref('dim_store') }} d on s.store_sk = d.store_sk
-- where s.store_id = 1
-- group by 1;

-- 5. Restore the size you noted in step 2
-- UPDATE WALMART_E2E.RAW.STORES SET SIZE = <original size> WHERE STORE = 1;
