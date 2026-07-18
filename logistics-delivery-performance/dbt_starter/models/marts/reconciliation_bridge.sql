with base as (
    select
        SUM(total_deliveries)       as total_deliveries,
        SUM(on_time_count)          as on_time_count,
        SUM(late_count)             as late_count,
        SUM(unmeasurable_count)     as unmeasurable_count,
        SUM(failed_count)           as failed_count
    from {{ ref('fct_sla_tracking') }}
),

bridge as (
    select
        total_deliveries,
        on_time_count,
        late_count,
        unmeasurable_count,
        failed_count,

        -- Your number: fail stance, everything in denominator
        round(on_time_count
            / nullif(total_deliveries, 0) * 100, 2)                        as my_rate_pct,

        -- Operations number: exclude nulls from denominator
        round(on_time_count
            / nullif(total_deliveries - unmeasurable_count, 0) * 100, 2)   as ops_rate_pct,

        -- CX number: exclude failed from denominator, nulls counted as late
        round(on_time_count
            / nullif(total_deliveries - failed_count, 0) * 100, 2)         as cx_rate_pct,

        -- Gap 1: how much of the spread is null timestamp handling
        round(on_time_count
            / nullif(total_deliveries - unmeasurable_count, 0) * 100, 2)
        - round(on_time_count
            / nullif(total_deliveries, 0) * 100, 2)                        as gap_null_handling_pct,

        -- Gap 2: how much is failed delivery treatment
        round(on_time_count
            / nullif(total_deliveries - unmeasurable_count, 0) * 100, 2)
        - round(on_time_count
            / nullif(total_deliveries - failed_count, 0) * 100, 2)         as gap_failed_treatment_pct,

        -- Policy label
        'null_timestamp = fail; failed_attempts = separate category'        as policy_applied

    from base
)

select * from bridge