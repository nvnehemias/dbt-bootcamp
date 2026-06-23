with question_tags as (

    select
        question_id,
        tag
    from {{ ref('int_question_tags') }}

),

tag_pairs as (

    select
        a.tag as tag_a,
        b.tag as tag_b,
        a.question_id
    from question_tags as a
    inner join question_tags as b
        on a.question_id = b.question_id
        and a.tag < b.tag

)

select
    tag_a,
    tag_b,
    count(distinct question_id) as cooccurrence_count
from tag_pairs
group by 1, 2
