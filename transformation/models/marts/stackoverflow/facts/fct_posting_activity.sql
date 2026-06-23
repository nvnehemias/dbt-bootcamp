with questions as (

    select
        'question' as post_type,
        question_created_at as posted_at
    from {{ ref('stg_stackoverflow__posts_questions') }}

),

answers as (

    select
        'answer' as post_type,
        answer_created_at as posted_at
    from {{ ref('stg_stackoverflow__posts_answers') }}

),

combined as (

    select * from questions
    union all
    select * from answers

)

select
    post_type,
    extract(hour from posted_at) as hour_of_day,
    format_date('%A', date(posted_at)) as day_of_week,
    extract(dayofweek from posted_at) as day_of_week_number,
    count(*) as post_count
from combined
group by 1, 2, 3, 4
