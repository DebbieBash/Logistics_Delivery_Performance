-- Business rule: driver names appearing under multiple IDs must be flagged
-- Returns unflagged cases where is_potential_rehire should be true
SELECT
    driver_name,
    count(distinct driver_id) as id_count

FROM {{ ref('dim_drivers') }}

GROUP BY driver_name

HAVING count(distinct driver_id) > 1

   AND MIN(is_potential_rehire) = false