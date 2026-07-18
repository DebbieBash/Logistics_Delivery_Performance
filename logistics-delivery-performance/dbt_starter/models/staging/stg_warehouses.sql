with src as (
    select * from {{ source('raw', 'raw_warehouses') }}
),

renamed as (
    select
        warehouse_id,
        warehouse_name,
        region,
        latitude,
        longitude,
        
        cast(opened_at as timestamp_ntz) as opened_at
    from src
)
select * from renamed


