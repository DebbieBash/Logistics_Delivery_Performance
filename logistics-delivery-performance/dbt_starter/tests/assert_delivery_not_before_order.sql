-- Business rule: delivered_at must never be before created_at
SELECT
    delivery_id,
    order_id,
    created_at,
    delivered_at

FROM {{ ref('fct_deliveries') }}

WHERE delivered_at is not null
AND delivered_at < created_at