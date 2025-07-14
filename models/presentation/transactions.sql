with

fct_transactions as (
    select *
    from {{ ref('fct_transactions') }}
)

, dim_products as (
    select *
    from {{ ref('dim_products') }}
)

, dim_customers as (
    select *
    from {{ ref('dim_customers') }}
)

, final as (
    select
        fct_transactions.transaction_id
        , fct_transactions.product_id
        , fct_transactions.customer_id

        , fct_transactions.transaction_date
        , dim_products.product_name
        , fct_transactions.quantity
        , dim_products.product_price_gbp
        , dim_products.product_category
        , dim_products.product_subcategory

        , dim_customers.customer_country_code
        , dim_customers.customer_age
        , dim_customers.customer_signup_date
        , dim_customers.first_transaction_date
        , dim_customers.last_transaction_date
        , dim_customers.months_active_as_customer

        , dim_customers.customer_spending_category
        , dim_customers.customer_purchase_frequency_category
        , dim_customers.customer_product_diversity_category
    from fct_transactions
    left join dim_products
        on fct_transactions.product_id = dim_products.product_id
    left join dim_customers
        on fct_transactions.customer_id = dim_customers.customer_id
)

select *
from final
