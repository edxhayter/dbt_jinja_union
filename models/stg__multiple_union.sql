{% set years =  ['2022', '2023', '2024'] %}

{% for year in years %}
  select 
      *,
      '{{ year }}' as year
  from {{ ref('sales_' ~ year) }}
{% if not loop.last -%} union all {%- endif %}
{% endfor %}