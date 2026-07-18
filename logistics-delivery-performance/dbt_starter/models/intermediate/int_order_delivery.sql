with orders as (
    select *
    from {{ ref('int_orders') }}
),

deliveries as (
    select *
    from {{ ref('int_deliveries') }}
),

joined as (
    select
        d.delivery_id,
        d.order_id,
        d.driver_id,


        -- Delivery event timestamps
        d.attempted_at,
        d.delivered_at,
        d.delivery_event_ts,

        -- Order timestamps
        o.created_at,
        o.promised_delivery_at,
        o.sla_hours,

        -- Delivery duration (actual)
        datediff('hour', o.created_at, d.delivery_event_ts) as delivery_duration_hours,

        -- Lateness duration (only if delivered)
        case 
            when d.delivered_at is not null then
                datediff('hour', o.promised_delivery_at, d.delivered_at)
            else null
        end as lateness_hours,

        -- SLA breach flag
        case
            when d.delivered_at is null then false
            when d.delivered_at > o.promised_delivery_at then true
            else false
        end as is_sla_breached,

        -- On-time flag
        case
            when d.delivered_at is not null 
            and d.delivered_at <= o.promised_delivery_at then true
            else false
        end as is_on_time

    from deliveries d
    left join orders o
        on d.order_id = o.order_id
)

select * from joined
