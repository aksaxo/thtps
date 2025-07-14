with

stg_postgres__transactions as (
    select *
    from {{ ref('stg_postgres__transactions') }}
)

, final as (
    select
        -- ids
        transaction_id
        , customer_id
        , product_id

        -- numerics
        , quantity

        -- dates
        , transaction_date
    from stg_postgres__transactions
)

select *
from final
