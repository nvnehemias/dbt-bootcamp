with questions as (

    select
        question_id,
        tags
    from {{ ref('stg_stackoverflow__posts_questions') }}
    where tags is not null
        and trim(tags) != ''

),

unnested as (

    select
        question_id,
        trim(tag) as tag
    from questions,
        unnest(split(tags, '|')) as tag
    where trim(tag) != ''

)

select distinct
    question_id,
    tag
from unnested
