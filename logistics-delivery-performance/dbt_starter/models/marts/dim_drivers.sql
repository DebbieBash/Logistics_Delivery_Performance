with drivers as (
    select *
    from {{ ref('stg_drivers') }}
),

-- Flag driver names that appear more than once (potential rehires)
name_counts as (
    select
        driver_name,
        count(distinct driver_id) as id_count
    from drivers
    group by driver_name
),

final as (
    select
        d.driver_id,
        d.driver_name,
        d.home_region,
        d.employment_status,
        d.hired_at,
        d.terminated_at,

        -- Derived fields
        case
            when d.terminated_at is null then true
            else false
        end as is_active,

        datediff('day', d.hired_at, coalesce(d.terminated_at, current_timestamp())) as tenure_days,

        -- DQ flag: same name, multiple IDs (assumption 5)
        case
            when n.id_count > 1 then true
            else false
        end as is_potential_rehire

    from drivers d
    left join name_counts n
        on d.driver_name = n.driver_name
)

select * from final