with

source as (
    select *
    from {{ source('public', 'transactions') }}
)

, final as (
    select
        -- ids
        id as transaction_id
        , customer_id
        , product_id
        -- numerics
        , quantity
        -- dates
        , transaction_date::date as transaction_date
    from source
)

select *
from final
