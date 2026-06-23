with source as (

    select * from {{ source('stackoverflow', 'comments') }}

),

renamed as (

    select
        id as comment_id,
        post_id,
        user_id as commenter_user_id,
        user_display_name as commenter_display_name,
        text as comment_text,
        score as comment_score,
        creation_date as comment_created_at

    from source
    where id is not null
        {{ stackoverflow_dev_filter('creation_date') }}

)

select * from renamed
