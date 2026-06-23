with questions as (

    select
        date_trunc(question_created_at, month) as activity_month,
        'question' as post_type,
        count(*) as post_count
    from {{ ref('stg_stackoverflow__posts_questions') }}
    group by 1, 2

),

answers as (

    select
        date_trunc(answer_created_at, month) as activity_month,
        'answer' as post_type,
        count(*) as post_count
    from {{ ref('stg_stackoverflow__posts_answers') }}
    group by 1, 2

),

combined as (

    select * from questions
    union all
    select * from answers

),

monthly_totals as (

    select
        activity_month,
        sum(post_count) as total_post_count
    from combined
    group by 1

)

select
    combined.activity_month,
    combined.post_type,
    combined.post_count,
    monthly_totals.total_post_count,
    lag(combined.post_count) over (
        partition by combined.post_type
        order by combined.activity_month
    ) as prior_month_post_count,
    safe_divide(
        combined.post_count - lag(combined.post_count) over (
            partition by combined.post_type
            order by combined.activity_month
        ),
        lag(combined.post_count) over (
            partition by combined.post_type
            order by combined.activity_month
        )
    ) as month_over_month_growth_rate,
    safe_divide(
        combined.post_count - lag(combined.post_count, 12) over (
            partition by combined.post_type
            order by combined.activity_month
        ),
        lag(combined.post_count, 12) over (
            partition by combined.post_type
            order by combined.activity_month
        )
    ) as year_over_year_growth_rate
from combined
inner join monthly_totals using (activity_month)
