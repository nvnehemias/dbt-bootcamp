{% macro stackoverflow_dev_filter(date_column, relation_alias=none) -%}
    {%- if target.name == 'dev' -%}
        {%- set prefix = relation_alias ~ '.' if relation_alias else '' -%}
        and {{ prefix }}{{ date_column }} >= timestamp('{{ var("dev_start_date") }}')
    {%- endif -%}
{%- endmacro %}

{% macro stackoverflow_is_dev() -%}
    {{ return(target.name == 'dev') }}
{%- endmacro %}
