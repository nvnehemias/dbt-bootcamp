with source as (

    select * from {{ source('stackoverflow', 'users') }}

),

renamed as (

    select
        id as user_id,
        reputation,
        creation_date as user_created_at,
        last_access_date as last_access_at,
        display_name,
        location,
        about_me,
        views as profile_views,
        up_votes,
        down_votes,
        age,
        profile_image_url,
        website_url

    from source
    where id is not null
        {% if target.name == 'dev' %}
            and (
                creation_date >= timestamp('{{ var("dev_start_date") }}')
                or last_access_date >= timestamp('{{ var("dev_start_date") }}')
            )
        {% endif %}

)

select * from renamed
