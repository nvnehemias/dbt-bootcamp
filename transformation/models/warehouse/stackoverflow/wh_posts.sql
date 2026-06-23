with questions as (

    select * from {{ ref('stg_stackoverflow__posts_questions') }}

),

comment_counts as (

    select
        post_id as question_id,
        count(*) as comment_count_derived
    from {{ ref('stg_stackoverflow__comments') }}
    group by 1

),

tag_lists as (

    select
        question_id,
        string_agg(tag, ', ' order by tag) as tag_list,
        count(*) as tag_count
    from {{ ref('int_question_tags') }}
    group by 1

)

select
    questions.question_id,
    questions.title,
    questions.body,
    questions.tags as raw_tags,
    tag_lists.tag_list,
    coalesce(tag_lists.tag_count, 0) as tag_count,
    questions.score,
    questions.view_count,
    questions.answer_count,
    coalesce(comment_counts.comment_count_derived, questions.comment_count, 0) as comment_count,
    questions.favorite_count,
    questions.accepted_answer_id,
    questions.accepted_answer_id is not null as has_accepted_answer,
    questions.owner_user_id,
    questions.owner_display_name,
    questions.question_created_at,
    questions.last_activity_at,
    questions.last_edit_at,
    questions.link
from questions
left join comment_counts using (question_id)
left join tag_lists using (question_id)
