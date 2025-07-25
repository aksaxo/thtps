with

stg_postgres__customers as (
    select *
    from {{ ref('stg_postgres__customers') }}
)

, int_customers__segmented as (
    select *
    from {{ ref('int_customers__segmented') }}
)

, final as (
    select
        -- ids
        int_customers__segmented.customer_id

        -- strings
        , stg_postgres__customers.first_name
        , stg_postgres__customers.last_name
        , stg_postgres__customers.email
        , stg_postgres__customers.customer_country_code

        -- numerics
        , stg_postgres__customers.customer_age

        -- dates
        , stg_postgres__customers.customer_signup_date
        , int_customers__segmented.first_transaction_date
        , int_customers__segmented.last_transaction_date

        -- metrics
        , int_customers__segmented.months_active_as_customer
        , int_customers__segmented.total_spending
        , int_customers__segmented.total_transactions
        , int_customers__segmented.total_unique_products_ordered
        , int_customers__segmented.average_spending_per_month
        , int_customers__segmented.average_transactions_per_month
        , int_customers__segmented.average_number_of_new_products_ordered_per_month

        -- segments
        , int_customers__segmented.customer_spending_category
        , int_customers__segmented.customer_purchase_frequency_category
        , int_customers__segmented.customer_product_diversity_category

    from int_customers__segmented
    left join stg_postgres__customers
        on int_customers__segmented.customer_id = stg_postgres__customers.customer_id
)

select *
from final
