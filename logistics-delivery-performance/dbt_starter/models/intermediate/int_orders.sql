with orders as (
    SELECT *
    from {{ ref('stg_orders')}}

),

cleaned as (
    select
        order_id,
        customer_id,
        origin_warehouse_id,
        dest_region,

        lower(service_level) as service_level,
        package_weight_kg,

        promised_delivery_at,
        created_at,

        case 
            when lower(service_level) = 'express' then 24
            when lower(service_level) = 'priority' then 48
            when lower(service_level) = 'standard' then 72
            else null
        end as sla_hours
    from orders
)

select * from cleaned