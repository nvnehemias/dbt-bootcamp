with source as (

    select * from {{ source('stackoverflow', 'votes') }}

),

renamed as (

    select
        id as vote_id,
        post_id,
        vote_type_id,
        creation_date as vote_created_at,
        null as voter_user_id

    from source
    where id is not null
        {{ stackoverflow_dev_filter('creation_date') }}

)

select * from renamed
