with src as (
    select * from {{ source('raw', 'raw_drivers') }}
),

renamed as (
    select
        driver_id,
        driver_name,
        home_region,
        employment_status,
        
        cast(hired_at as timestamp_ntz)      as hired_at,
        cast(terminated_at as timestamp_ntz) as terminated_at
    from src
)
select * from renamed