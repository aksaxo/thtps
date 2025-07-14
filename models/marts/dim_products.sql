with

stg_postgres__products as (
    select *
    from {{ ref('stg_postgres__products') }}
)

, final as (
    select
        -- ids
        product_id

        -- strings
        , product_name
        , product_category
        , product_subcategory

        -- numerics
        , price_gbp
    from stg_postgres__products
)

select *
from final
