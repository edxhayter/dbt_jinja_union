# Using Jinja for dynamic unions

## Simple Union of Same Structured Data

### Intro

This repo is designed to demonstrate how dbt using JINJA can simplify SQL code and make developers lives easier. A common occurence in data prep is to consolidate data of the same structure from different files or sources into a consolidated table. Unions, stacking data on top of each other is the means of achieving this consolidated outcome. In software like Tableau Prep and Alteryx, functionality is offered for wild-card unions that union same-structured tables quickly with a few button clicks. In languages such as Python this functionality can be replicated with a loop. In SQL, a union is constructed with a keyword (UNION ALL or UNION DISTINCT) between queries that produce an output of matching schema.

    UNION DISTINCT will deduplicate the output whereas UNION ALL as the name implies will return all rows regardless of duplication.

The gripe with a setup like this is if you have multiple data sources to consolidate, whether it be a table for each country, a table for each year or month of data, the task of manually listing out all the sources one after another seperated by a UNION keyword is tedious and not very easily updated to new data. If you have a new year of data you would need to add to the query with a new SELECT statement from the new year of data.

JINJA is the templating language that dbt uses, at compilation REF() and SOURCE() functions replace the value specified by values gathered from accompanying .yml files.

E.G. `{{ source('source system, 'source model') }}` at runtime can be compiled as `snowflake_database.snowflake_schema.table` at runtime based on specifications made in a `sources.yml` file (the name could be different - depends on your own project and the naming convention you opt for).

The other use case for JINJA is custom SQL statements - this is the use case we are going to use here. Rather than write out a long query connected by the UNION keyword, we will use JINJA to specify a loop of code to compile at runtime. Before we breakdown the JINJA and SQL code, I'll briefly discuss the source data for this simple demonstration.

### Source Data
![Sales 2022](https://github.com/edxhayter/dbt_jinja_union/blob/edxhayter-patch-1/assets/2022_table_preview.png)
![Sales 2023](https://github.com/edxhayter/dbt_jinja_union/blob/edxhayter-patch-1/assets/2023_table_preview.png)
![Sales 2024](https://github.com/edxhayter/dbt_jinja_union/blob/edxhayter-patch-1/assets/2024_table_preview.png)

For the purpose of the demonstration I have kept the actual data in the tables very simple (1 line with same data in it repeated across columns so we can clearly see the union occur successfully). I have opted for dbt seeds here just so that the data can be generated quickly from within the project. All that is required after setting up the project is to run the `dbt seed` command.

### Model

Now moving on to the model that does the simple yet effective magic:

```
{% set years =  ['2022', '2023', '2024'] %}

{% for year in years %}
  select 
      *,
      '{{ year }}' as year
  from {{ ref('sales_' ~ year) }}
{% if not loop.last -%} union all {%- endif %}
{% endfor %}
```

At the start of the model we use JINJA to set some variables here it is a list of years. Next we set a for loop and within that we have a query, so each variable in the list goes through the loop and we read in data. For 2022 we read in all the columns and an additional column with the year specified using `{{ year }}` indicating to take the variable, from model `sales_2022` which is what the seed is called in this project. The `~` indicates a concatenation in JINJA, the last line of code says if this is not the last item in the FOR loop then also print `union all` setting up the query for the next iteration. We can press the compilation button in dbt Cloud to see how this compiles:

```
  select 
      *,
      '2022' as year
  from TIL_PORTFOLIO_PROJECTS.EH_PREPPIN_DBT.sales_2022
union all

  select 
      *,
      '2023' as year
  from TIL_PORTFOLIO_PROJECTS.EH_PREPPIN_DBT.sales_2023
union all

  select 
      *,
      '2024' as year
  from TIL_PORTFOLIO_PROJECTS.EH_PREPPIN_DBT.sales_2024

```
Keen observers might note that the current set up is static in the sense that we provide a list of variables. We can actually improve upon the model and make it more dynamic by using built-in Python modules to make the variable generation dynamic:

```
{% set current_year = modules.datetime.datetime.now().year %}
{% set years = range(2022, current_year + 1) %}

{% for year in years %}
  select 
      *,
      '{{ year }}' as year
  from {{ ref('sales_' ~ year) }}
{% if not loop.last -%} union all {%- endif %}
{% endfor %}
```
The current year is then generated from the python module and range is inclusive of the start value but exclusive of the last value hence we add one to the current year to select 2022 up to 2024.

The result of both of these queries is a unioned table and an approach that scales up:

![Unioned Data](https://github.com/edxhayter/dbt_jinja_union/blob/edxhayter-patch-1/assets/unioned_table.png)

## Advanced Union of Data with Varying Structures (Requires dbt Utils)
Update Coming Soon
