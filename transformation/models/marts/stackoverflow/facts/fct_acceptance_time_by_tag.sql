with accepted_answers as (

    select
        answers.question_id,
        answers.hours_to_answer,
        question_tags.tag
    from {{ ref('wh_answers') }} as answers
    inner join {{ ref('int_question_tags') }} as question_tags
        on answers.question_id = question_tags.question_id
    where answers.is_accepted

)

select
    tag,
    count(*) as accepted_answer_count,
    avg(hours_to_answer) as avg_hours_to_accepted_answer,
    approx_quantiles(hours_to_answer, 2)[offset(1)] as median_hours_to_accepted_answer,
    min(hours_to_answer) as min_hours_to_accepted_answer,
    max(hours_to_answer) as max_hours_to_accepted_answer
from accepted_answers
group by 1
