with

stg_postgres__customers as (
    select *
    from {{ ref('stg_postgres__customers') }}
)

, stg_postgres__products as (
    select *
    from {{ ref('stg_postgres__products') }}
)

, stg_postgres__transactions as (
    select *
    from {{ ref('stg_postgres__transactions') }}
)

-- Create table of transactions along with product and customer data to then implement segmentation logic
, aggregated_customer_transaction_info as (
    select
        stg_postgres__transactions.customer_id
        , sum(stg_postgres__products.price_gbp * stg_postgres__transactions.quantity) as total_spending
        , count(distinct stg_postgres__transactions.transaction_id) as total_transactions
        , count(distinct stg_postgres__products.product_id) as total_unique_products_ordered
        , min(transaction_date) as first_transaction
        , max(transaction_date) as last_transaction

        -- Average number of days in month is 30.4
        , nullif((max(transaction_date) - min(transaction_date))::float / 30.4, 0) as months_active
    from stg_postgres__transactions
    left join stg_postgres__customers
        on stg_postgres__transactions.customer_id = stg_postgres__customers.customer_id
    left join stg_postgres__products
        on stg_postgres__transactions.product_id = stg_postgres__products.product_id
    group by 1
)

-- Calculate e.g. average spending over time active. This means that metrics are calculated proportional to the time a customer has spent with us.
, customer_transaction_metrics_phased_by_time_active as (
    select
        aggregated_customer_transaction_info.customer_id
        , first_transaction
        , last_transaction
        , months_active
        , total_spending
        , total_transactions
        , total_unique_products_ordered
        , aggregated_customer_transaction_info.total_spending / aggregated_customer_transaction_info.months_active as average_spending_per_month
        , aggregated_customer_transaction_info.total_transactions / aggregated_customer_transaction_info.months_active as average_transactions_per_month
        , aggregated_customer_transaction_info.total_unique_products_ordered / aggregated_customer_transaction_info.months_active as average_number_of_new_products_ordered_per_month
    from aggregated_customer_transaction_info
)

, final as (
    select
        customer_transaction_metrics_phased_by_time_active.customer_id
        , customer_transaction_metrics_phased_by_time_active.first_transaction
        , customer_transaction_metrics_phased_by_time_active.last_transaction
        , customer_transaction_metrics_phased_by_time_active.months_active
        , customer_transaction_metrics_phased_by_time_active.total_spending
        , customer_transaction_metrics_phased_by_time_active.total_transactions
        , customer_transaction_metrics_phased_by_time_active.total_unique_products_ordered
        , customer_transaction_metrics_phased_by_time_active.average_spending_per_month
        , customer_transaction_metrics_phased_by_time_active.average_transactions_per_month
        , customer_transaction_metrics_phased_by_time_active.average_number_of_new_products_ordered_per_month

        -- The boundaries for each segment are defined loosely - I've made histograms to see distribution of customers and segment them on an ad-hoc basis looking on the distribution's shape
        -- I didn't segment by e.g. top 1/3, middle 1/3, and bottom 1/3 because I think that can be sort of dismissive of more 'real' customer segments I see by looking at a locally made histogram (?)
        -- A small number of customers only had 1 order - this logic automatically puts them in the 'No Segment' category
        , case
            when customer_transaction_metrics_phased_by_time_active.average_spending_per_month > 20 then 'High'
            when customer_transaction_metrics_phased_by_time_active.average_spending_per_month > 6 then 'Medium'
            when customer_transaction_metrics_phased_by_time_active.average_spending_per_month > 0 then 'Low'
            else 'No Segment'
        end as spending_category
        , case
            when customer_transaction_metrics_phased_by_time_active.average_transactions_per_month > 0.15 then 'Frequent'
            when customer_transaction_metrics_phased_by_time_active.average_transactions_per_month > 0.1 then 'Occasional'
            when customer_transaction_metrics_phased_by_time_active.average_transactions_per_month > 0 then 'Rare'
            else 'No Segment'
        end as purchase_frequency_category
        , case
            when customer_transaction_metrics_phased_by_time_active.average_number_of_new_products_ordered_per_month > 0.12 then 'Diverse'
            when customer_transaction_metrics_phased_by_time_active.average_number_of_new_products_ordered_per_month > 0 then 'Focused'
            else 'No Segment'
        end as product_diversity_category
    from customer_transaction_metrics_phased_by_time_active
)

select *
from final
