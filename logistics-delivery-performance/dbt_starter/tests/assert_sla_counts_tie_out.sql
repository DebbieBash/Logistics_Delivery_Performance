-- Business rule: all delivery categories must sum to total_deliveries
-- A non-zero result means the numbers don't tie out
SELECT
    promised_month,
    service_level,
    total_deliveries,
    on_time_count + late_count + unmeasurable_count + failed_count as sum_of_parts

FROM {{ ref('fct_sla_tracking') }}

WHERE total_deliveries != on_time_count + late_count + unmeasurable_count + failed_count