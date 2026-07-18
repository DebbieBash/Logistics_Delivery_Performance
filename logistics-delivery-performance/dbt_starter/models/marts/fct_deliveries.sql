with order_delivery as (
    select *
    from {{ ref('int_order_delivery') }}
),

final as (
    select
        -- Primary key
        delivery_id,

        -- Foreign keys
        order_id,
        driver_id,


        -- Delivery timestamps
        attempted_at,
        delivered_at,
        delivery_event_ts,

        -- Order timestamps
        created_at,
        promised_delivery_at,

        -- Metrics
        delivery_duration_hours,
        lateness_hours,
        is_sla_breached,
        is_on_time,

        -- Optional surrogate key
        {{ dbt_utils.generate_surrogate_key(['delivery_id']) }} as delivery_sk
    from order_delivery
)

select * from final
