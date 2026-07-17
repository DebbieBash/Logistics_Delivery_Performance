with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        origin_warehouse_id,
        dest_region,
        service_level,
        package_weight_kg,
        cast(promised_delivery_at as timestamp_ntz) as promised_delivery_at,
        cast(created_at as timestamp_ntz)            as created_at
    from source
)

select * from renamed