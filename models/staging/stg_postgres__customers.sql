with

source as (
    select *
    from {{ source('public', 'customers') }}
)

, final as (
    select
        -- ids
        id as customer_id

        -- strings
        , first_name
        , last_name
        , email
        , country as customer_country_code

        -- numerics
        , age as customer_age

        -- dates
        , signup_date::date as customer_signup_date
    from source
)

select *
from final
