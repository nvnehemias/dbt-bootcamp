select
    tag,
    source_tag_usage_count,
    question_count,
    answered_question_count,
    unanswered_question_count,
    total_answer_count,
    avg_question_score,
    avg_question_view_count,
    answer_rate,
    unanswered_rate,
    case popularity_tier_ntile
        when 1 then 'top'
        when 2 then 'high'
        when 3 then 'medium'
        else 'niche'
    end as popularity_tier
from {{ ref('wh_tags') }}
