with source as (

    select * from {{ source('stackoverflow', 'tags') }}

),

renamed as (

    select
        tag_name as tag,
        count as tag_usage_count,
        excerpt_post_id,
        wiki_post_id

    from source
    where tag_name is not null

)

select * from renamed
