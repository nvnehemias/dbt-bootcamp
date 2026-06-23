with answer_tags as (

    select
        answers.owner_user_id as user_id,
        answers.owner_display_name as display_name,
        question_tags.tag,
        answers.answer_id,
        answers.is_accepted,
        answers.score as answer_score
    from {{ ref('wh_answers') }} as answers
    inner join {{ ref('int_question_tags') }} as question_tags
        on answers.question_id = question_tags.question_id
    where answers.owner_user_id is not null

),

aggregated as (

    select
        user_id,
        max(display_name) as display_name,
        tag,
        count(*) as answer_count_on_tag,
        countif(is_accepted) as accepted_answer_count_on_tag,
        safe_divide(countif(is_accepted), count(*)) as acceptance_rate_on_tag,
        avg(answer_score) as avg_answer_score_on_tag
    from answer_tags
    group by 1, 3

),

ranked as (

    select
        *,
        row_number() over (
            partition by tag
            order by acceptance_rate_on_tag desc, answer_count_on_tag desc
        ) as specialist_rank_on_tag
    from aggregated
    where answer_count_on_tag >= {{ var('specialist_min_answers') }}

)

select
    user_id,
    display_name,
    tag,
    answer_count_on_tag,
    accepted_answer_count_on_tag,
    acceptance_rate_on_tag,
    avg_answer_score_on_tag,
    specialist_rank_on_tag,
    case
        when specialist_rank_on_tag = 1 then 'primary'
        when specialist_rank_on_tag <= 3 then 'secondary'
        else 'specialist'
    end as specialist_tier,
    specialist_rank_on_tag <= {{ var('specialist_top_n') }} as is_top_specialist
from ranked
