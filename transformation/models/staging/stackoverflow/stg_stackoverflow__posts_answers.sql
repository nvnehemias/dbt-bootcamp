with source as (

    select * from {{ source('stackoverflow', 'posts_answers') }}

),

renamed as (

    select
        id as answer_id,
        parent_id as question_id,
        body,
        score,
        owner_user_id,
        owner_display_name,
        creation_date as answer_created_at,
        last_activity_date as last_activity_at,
        last_edit_date as last_edit_at,
        last_editor_user_id,
        last_editor_display_name,
        community_owned_date as community_owned_at

    from source
    where id is not null
        and parent_id is not null
        {{ stackoverflow_dev_filter('creation_date') }}

)

select * from renamed
