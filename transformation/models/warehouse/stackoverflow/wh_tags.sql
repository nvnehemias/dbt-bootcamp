with tags as (

    select * from {{ ref('stg_stackoverflow__tags') }}

),

question_tags as (

    select
        tag,
        count(distinct question_id) as question_count
    from {{ ref('int_question_tags') }}
    group by 1

),

question_metrics as (

    select
        int_question_tags.tag,
        count(distinct int_question_tags.question_id) as tagged_question_count,
        count(distinct wh_posts.question_id) as question_count_with_metadata,
        countif(wh_posts.has_accepted_answer) as answered_question_count,
        countif(not wh_posts.has_accepted_answer) as unanswered_question_count,
        sum(wh_posts.answer_count) as total_answer_count,
        avg(wh_posts.score) as avg_question_score,
        avg(wh_posts.view_count) as avg_question_view_count
    from {{ ref('int_question_tags') }} as int_question_tags
    inner join {{ ref('wh_posts') }} as wh_posts
        on int_question_tags.question_id = wh_posts.question_id
    group by 1

)

select
    coalesce(tags.tag, question_metrics.tag) as tag,
    coalesce(tags.tag_usage_count, 0) as source_tag_usage_count,
    coalesce(question_tags.question_count, question_metrics.tagged_question_count, 0) as question_count,
    coalesce(question_metrics.answered_question_count, 0) as answered_question_count,
    coalesce(question_metrics.unanswered_question_count, 0) as unanswered_question_count,
    coalesce(question_metrics.total_answer_count, 0) as total_answer_count,
    question_metrics.avg_question_score,
    question_metrics.avg_question_view_count,
    safe_divide(
        coalesce(question_metrics.answered_question_count, 0),
        nullif(coalesce(question_metrics.tagged_question_count, 0), 0)
    ) as answer_rate,
    safe_divide(
        coalesce(question_metrics.unanswered_question_count, 0),
        nullif(coalesce(question_metrics.tagged_question_count, 0), 0)
    ) as unanswered_rate,
    ntile(4) over (order by coalesce(question_tags.question_count, question_metrics.tagged_question_count, 0) desc) as popularity_tier_ntile
from tags
full outer join question_metrics using (tag)
left join question_tags using (tag)
