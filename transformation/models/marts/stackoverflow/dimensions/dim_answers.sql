select
    answer_id,
    question_id,
    question_title,
    score,
    owner_user_id,
    owner_display_name,
    answer_created_at,
    last_activity_at,
    question_created_at,
    question_score,
    question_view_count,
    question_owner_user_id,
    is_accepted,
    hours_to_answer,
    {{ categorize_score('score') }} as score_category
from {{ ref('wh_answers') }}
