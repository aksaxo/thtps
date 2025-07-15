{{ config(materialized = 'table' , schema = 'utilities') }}

with

country_lookup as (
    select *
    from {{ ref('country_lookup') }}
)

, final as (
    select
        country_code
        , country_name
        , alt_country_name
        , continent
    from country_lookup
)

select *
from final
