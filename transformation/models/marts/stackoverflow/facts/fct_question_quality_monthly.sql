with questions as (

    select
        date_trunc(question_created_at, month) as activity_month,
        score,
        view_count,
        has_accepted_answer
    from {{ ref('wh_posts') }}

)

select
    activity_month,
    count(*) as question_count,
    avg(score) as avg_question_score,
    avg(view_count) as avg_view_count,
    safe_divide(countif(has_accepted_answer), count(*)) as accepted_answer_rate,
    approx_quantiles(score, 2)[offset(1)] as median_question_score
from questions
group by 1
