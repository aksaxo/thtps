with

source as (
    select *
    from {{ source('public', 'products') }}
)

, final as (
    select
        -- ids
        id as product_id

        -- strings
        , name as product_name
        , category as product_category
        , split_part(category, '-', 2) as product_subcategory

        -- numerics
        , price_gbp as product_price_gbp
    from source
)

select *
from final
