{% macro categorize_score(score_column) -%}
    case
        when {{ score_column }} < 0 then 'negative'
        when {{ score_column }} between 0 and 4 then 'low'
        when {{ score_column }} between 5 and 14 then 'medium'
        when {{ score_column }} >= 15 then 'high'
        else 'unknown'
    end
{%- endmacro %}

{% macro categorize_reputation(reputation_column) -%}
    case
        when {{ reputation_column }} < 100 then 'newcomer'
        when {{ reputation_column }} < 1000 then 'contributor'
        when {{ reputation_column }} < 10000 then 'expert'
        else 'elite'
    end
{%- endmacro %}

{% macro categorize_activity_status(days_since_last_activity_column) -%}
    case
        when {{ days_since_last_activity_column }} is null then 'unknown'
        when {{ days_since_last_activity_column }} <= 90 then 'active'
        when {{ days_since_last_activity_column }} <= 365 then 'dormant'
        else 'inactive'
    end
{%- endmacro %}
