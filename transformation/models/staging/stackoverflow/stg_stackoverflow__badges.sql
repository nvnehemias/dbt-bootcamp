with source as (

    select * from {{ source('stackoverflow', 'badges') }}

),

renamed as (

    select
        id as badge_id,
        user_id,
        name as badge_name,
        date as badge_awarded_at,
        class as badge_class,
        tag_based as is_tag_based

    from source
    where id is not null
        {{ stackoverflow_dev_filter('date') }}

)

select * from renamed
