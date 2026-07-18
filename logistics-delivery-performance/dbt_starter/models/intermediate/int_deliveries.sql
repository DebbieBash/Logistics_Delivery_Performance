with deliveries as (
    select *
    from {{ ref('stg_deliveries') }}
),

cleaned as (
    select
        delivery_id,
        order_id,
        driver_id,
        carrier,
        lower(delivery_status)                as delivery_status,
        failure_reason,
        picked_up_at,
        attempted_at,
        delivered_at,
        coalesce(delivered_at, attempted_at)  as delivery_event_ts,
        case 
            when delivered_at is not null then true
            else false
        end                                   as is_completed
    from deliveries
)

select * from cleaned
