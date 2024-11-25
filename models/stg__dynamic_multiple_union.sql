{% set current_year = modules.datetime.datetime.now().year %}
{% set years = range(2022, current_year + 1) %}

{% for year in years %}
  select 
      *,
      '{{ year }}' as year
  from {{ ref('sales_' ~ year) }}
{% if not loop.last -%} union all {%- endif %}
{% endfor %}