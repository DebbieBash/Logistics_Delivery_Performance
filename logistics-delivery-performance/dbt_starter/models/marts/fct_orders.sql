with order_delivery as (
    select *
    from {{ ref('int_order_delivery') }}
),

-- Collapse delivery attempts into a single order record
aggregated as (
    select
        order_id,

        -- Choose the actual delivery timestamp (latest delivered_at)
        max(delivered_at) as actual_delivery_at,

        -- Order-level timestamps
        min(created_at) as created_at,
        max(promised_delivery_at) as promised_delivery_at,

        -- SLA window
        max(sla_hours) as sla_hours,

        -- Delivery duration (from order creation to actual delivery)
        datediff(
            'hour',
            min(created_at),
            max(delivery_event_ts)
        ) as delivery_duration_hours,

        -- Lateness (only if delivered)
        case 
            when max(delivered_at) is not null then
                datediff(
                    'hour',
                    max(promised_delivery_at),
                    max(delivered_at)
                )
            else null
        end as lateness_hours,

        -- SLA breach flag
        case
            when max(delivered_at) is null then false
            when max(delivered_at) > max(promised_delivery_at) then true
            else false
        end as is_sla_breached,

        -- On-time flag
        case
            when max(delivered_at) is not null
            and max(delivered_at) <= max(promised_delivery_at)
            then true
            else false
        end as is_on_time

    from order_delivery
    group by order_id
),

final as (
    select
        order_id,
        actual_delivery_at,
        created_at,
        promised_delivery_at,
        sla_hours,
        delivery_duration_hours,
        lateness_hours,
        is_sla_breached,
        is_on_time,

        -- Optional surrogate key
        {{ dbt_utils.generate_surrogate_key(['order_id']) }} as order_sk

    from aggregated
)

select * from final
