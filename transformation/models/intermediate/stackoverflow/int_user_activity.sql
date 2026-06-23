with questions as (

    select
        owner_user_id as user_id,
        question_created_at as activity_at
    from {{ ref('stg_stackoverflow__posts_questions') }}
    where owner_user_id is not null

),

answers as (

    select
        owner_user_id as user_id,
        answer_created_at as activity_at
    from {{ ref('stg_stackoverflow__posts_answers') }}
    where owner_user_id is not null

),

comments as (

    select
        commenter_user_id as user_id,
        comment_created_at as activity_at
    from {{ ref('stg_stackoverflow__comments') }}
    where commenter_user_id is not null

),

all_activity as (

    select * from questions
    union all
    select * from answers
    union all
    select * from comments

),

aggregated as (

    select
        user_id,
        countif(activity_at is not null) as total_activity_count,
        max(activity_at) as last_activity_at
    from all_activity
    group by 1

),

question_counts as (

    select
        owner_user_id as user_id,
        count(*) as question_count
    from {{ ref('stg_stackoverflow__posts_questions') }}
    where owner_user_id is not null
    group by 1

),

answer_counts as (

    select
        owner_user_id as user_id,
        count(*) as answer_count
    from {{ ref('stg_stackoverflow__posts_answers') }}
    where owner_user_id is not null
    group by 1

),

comment_counts as (

    select
        commenter_user_id as user_id,
        count(*) as comment_count
    from {{ ref('stg_stackoverflow__comments') }}
    where commenter_user_id is not null
    group by 1

)

select
    aggregated.user_id,
    coalesce(question_counts.question_count, 0) as question_count,
    coalesce(answer_counts.answer_count, 0) as answer_count,
    coalesce(comment_counts.comment_count, 0) as comment_count,
    aggregated.total_activity_count,
    aggregated.last_activity_at,
    date_diff(current_date(), date(aggregated.last_activity_at), day) as days_since_last_activity
from aggregated
left join question_counts using (user_id)
left join answer_counts using (user_id)
left join comment_counts using (user_id)
