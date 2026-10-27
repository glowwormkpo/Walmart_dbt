{#
  Fails if any combination of the given columns appears more than once.
  Used to assert the grain of every model (e.g. store_id + dept_id + date_id).
  Written in-project instead of installing dbt_utils, so the project has no package dependencies.
#}
{% test unique_combination_of_columns(model, combination_of_columns) %}

select
    {{ combination_of_columns | join(', ') }},
    count(*) as row_count
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1

{% endtest %}
