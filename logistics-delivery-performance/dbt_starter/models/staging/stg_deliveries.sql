with src as (
    select * from {{ source('raw', 'raw_deliveries') }}
),

renamed as (
    select
        delivery_id,
        order_id,
        driver_id,
        carrier,
        delivery_status,
        failure_reason,
        
        cast(picked_up_at as timestamp_ntz)  as picked_up_at,
        cast(delivered_at as timestamp_ntz)  as delivered_at,
        cast(attempted_at as timestamp_ntz)  as attempted_at
    from src
)
select * from renamed