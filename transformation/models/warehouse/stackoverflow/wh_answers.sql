with answers as (

    select * from {{ ref('stg_stackoverflow__posts_answers') }}

),

questions as (

    select
        question_id,
        title as question_title,
        accepted_answer_id,
        question_created_at,
        score as question_score,
        view_count as question_view_count,
        owner_user_id as question_owner_user_id
    from {{ ref('stg_stackoverflow__posts_questions') }}

)

select
    answers.answer_id,
    answers.question_id,
    questions.question_title,
    answers.body,
    answers.score,
    answers.owner_user_id,
    answers.owner_display_name,
    answers.answer_created_at,
    answers.last_activity_at,
    questions.question_created_at,
    questions.question_score,
    questions.question_view_count,
    questions.question_owner_user_id,
    questions.accepted_answer_id = answers.answer_id as is_accepted,
    timestamp_diff(
        answers.answer_created_at,
        questions.question_created_at,
        hour
    ) as hours_to_answer
from answers
inner join questions using (question_id)
