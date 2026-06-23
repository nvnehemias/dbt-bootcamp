with source as (

    select * from {{ source('stackoverflow', 'posts_questions') }}

),

renamed as (

    select
        id as question_id,
        title,
        body,
        tags,
        score,
        view_count,
        answer_count,
        comment_count,
        favorite_count,
        accepted_answer_id,
        owner_user_id,
        owner_display_name,
        creation_date as question_created_at,
        last_activity_date as last_activity_at,
        last_edit_date as last_edit_at,
        last_editor_user_id,
        last_editor_display_name,
        community_owned_date as community_owned_at,
        null as link

    from source
    where id is not null
        {{ stackoverflow_dev_filter('creation_date') }}

)

select * from renamed
