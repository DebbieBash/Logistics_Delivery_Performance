with deliveries as (
    select *
    from {{ ref('stg_deliveries') }}
),

orders as (
    select *
    from {{ ref('stg_orders') }}
),

order_metrics as (
    select *
    from {{ ref('fct_orders') }}
),

joined as (
    select
        d.delivery_id,
        d.order_id,
        d.driver_id,
        d.carrier,
        d.delivery_status,
        d.delivered_at,
        o.service_level,
        o.dest_region,
        o.origin_warehouse_id,
        o.promised_delivery_at,
        m.is_on_time,
        m.is_sla_breached,
        date_trunc('month', o.promised_delivery_at) as promised_month
    from deliveries d
    left join orders o on d.order_id = o.order_id
    left join order_metrics m on d.order_id = m.order_id
),

aggregated as (
    select
        promised_month,
        service_level,
        dest_region,
        origin_warehouse_id,
        carrier,

        count(*)                                                as total_deliveries,
        count_if(is_on_time = true)                             as on_time_count,
        count_if(is_sla_breached = true)                        as late_count,
        count_if(delivered_at is null
            and delivery_status != 'failed')                    as unmeasurable_count,
        count_if(delivery_status = 'failed')                    as failed_count,

        round(count_if(is_on_time = true)
            / nullif(count(*), 0) * 100, 2)                     as on_time_rate_pct,
        round(count_if(is_sla_breached = true)
            / nullif(count(*), 0) * 100, 2)                     as late_rate_pct,
        round(count_if(delivered_at is null
            and delivery_status != 'failed')
            / nullif(count(*), 0) * 100, 2)                     as unmeasurable_rate_pct

    from joined
    group by
        promised_month,
        service_level,
        dest_region,
        origin_warehouse_id,
        carrier
)

select * from aggregated
