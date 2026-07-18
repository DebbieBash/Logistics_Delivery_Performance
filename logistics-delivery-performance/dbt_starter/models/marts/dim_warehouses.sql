with warehouses as (
    select *
    from {{ ref('stg_warehouses') }}
),

final as (
    select
        warehouse_id,
        warehouse_name,
        region,
        latitude,
        longitude,
        opened_at,

        -- Derived fields
        datediff('day', opened_at, current_timestamp()) as days_operational

    from warehouses
)

select * from final