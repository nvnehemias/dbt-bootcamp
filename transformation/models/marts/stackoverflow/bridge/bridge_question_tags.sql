select
    question_id,
    tag
from {{ ref('int_question_tags') }}
