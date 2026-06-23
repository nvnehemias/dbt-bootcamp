with users as (

    select * from {{ ref('stg_stackoverflow__users') }}

),

activity as (

    select * from {{ ref('int_user_activity') }}

),

badges as (

    select
        user_id,
        count(*) as badge_count,
        countif(badge_class = 1) as gold_badge_count,
        countif(badge_class = 2) as silver_badge_count,
        countif(badge_class = 3) as bronze_badge_count,
        countif(is_tag_based) as tag_based_badge_count
    from {{ ref('stg_stackoverflow__badges') }}
    group by 1

),

answers as (

    select
        answers.owner_user_id as user_id,
        count(*) as answers_given_count,
        countif(questions.accepted_answer_id = answers.answer_id) as accepted_answers_count
    from {{ ref('stg_stackoverflow__posts_answers') }} as answers
    left join {{ ref('stg_stackoverflow__posts_questions') }} as questions
        on answers.question_id = questions.question_id
    where answers.owner_user_id is not null
    group by 1

)

select
    users.user_id,
    users.display_name,
    users.reputation,
    users.user_created_at,
    users.last_access_at,
    users.location,
    users.profile_views,
    users.up_votes,
    users.down_votes,
    coalesce(activity.question_count, 0) as question_count,
    coalesce(activity.answer_count, 0) as answer_count,
    coalesce(activity.comment_count, 0) as comment_count,
    activity.last_activity_at,
    activity.days_since_last_activity,
    coalesce(badges.badge_count, 0) as badge_count,
    coalesce(badges.gold_badge_count, 0) as gold_badge_count,
    coalesce(badges.silver_badge_count, 0) as silver_badge_count,
    coalesce(badges.bronze_badge_count, 0) as bronze_badge_count,
    coalesce(badges.tag_based_badge_count, 0) as tag_based_badge_count,
    coalesce(answers.answers_given_count, 0) as answers_given_count,
    coalesce(answers.accepted_answers_count, 0) as accepted_answers_count,
    safe_divide(
        coalesce(answers.accepted_answers_count, 0),
        nullif(coalesce(answers.answers_given_count, 0), 0)
    ) as answer_acceptance_rate
from users
left join activity using (user_id)
left join badges using (user_id)
left join answers using (user_id)
