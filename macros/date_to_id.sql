{#
  Converts a DATE to an integer YYYYMMDD key (2010-02-05 -> 20100205),
  matching DATE_ID in the original WALMART_DATE_DIM.
  Dispatched so the same models compile on Snowflake and on DuckDB (used for local CI).
#}
{% macro date_to_id(date_column) -%}
    {{ return(adapter.dispatch('date_to_id', 'walmart_dbt')(date_column)) }}
{%- endmacro %}

{% macro snowflake__date_to_id(date_column) -%}
    to_number(to_char({{ date_column }}, 'YYYYMMDD'))
{%- endmacro %}

{% macro default__date_to_id(date_column) -%}
    cast(strftime({{ date_column }}, '%Y%m%d') as integer)
{%- endmacro %}
