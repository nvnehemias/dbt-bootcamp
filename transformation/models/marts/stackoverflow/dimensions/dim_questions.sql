with posts as (

    select * from {{ ref('wh_posts') }}

),

ranked as (

    select
        *,
        percent_rank() over (order by score) as score_percentile,
        percent_rank() over (order by view_count) as view_percentile
    from posts

)

select
    question_id,
    title,
    raw_tags,
    tag_list,
    tag_count,
    score,
    view_count,
    answer_count,
    comment_count,
    favorite_count,
    accepted_answer_id,
    has_accepted_answer,
    owner_user_id,
    owner_display_name,
    question_created_at,
    last_activity_at,
    last_edit_at,
    link,
    {{ categorize_score('score') }} as score_category,
    case
        when view_count < 100 then 'very_low'
        when view_count < 1000 then 'low'
        when view_count < 10000 then 'medium'
        else 'high'
    end as view_category,
    score_percentile,
    view_percentile,
    (
        score_percentile >= {{ var('hidden_gem_score_percentile') }}
        and view_percentile <= {{ var('hidden_gem_view_percentile') }}
    ) as is_hidden_gem,
    round((score_percentile - view_percentile), 4) as hidden_gem_score
from ranked
