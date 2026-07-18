# Logistics_Delivery_Performance
End-to-end logistics delivery performance pipeline for Cartwright Freightways. Investigates an 88% vs 79% on-time rate discrepancy, models null-timestamp handling as an explicit policy choice, and delivers a reconciliation mart all stakeholders can pull from.

The problem

Cartwright Freightways has two dashboards reporting different on-time delivery rates: one says 88%, the other 79%. The VP of Operations needs one number they can defend in front of a client and a regulator. The Head of Customer Experience and the Head of Network Operations disagree on what's causing the gap — and more fundamentally, on what "on-time" should even mean when the carrier feed drops delivery timestamps.

This project builds the data infrastructure to explain that gap. Every definitional choice is written down and defended. Both stakeholders get one mart — they can pull their own number from it and see exactly why it differs from the other's.


What I built

DeliverableStatusAssumptions & tradeoffs log✅ Complete
Data generator (Snowflake sandbox)✅ Complete
dbt project (staging → intermediate → marts)✅ Complete
Delivery performance mart✅ Complete
88% vs 79% reconciliation model✅ Complete
Data quality framework (15 tests, 3 business-rule)✅ Complete
Orchestration DAG design (Dagster)✅ Complete
Architecture diagram✅ Complete

The numbers

RateValuePolicyYour rate (fail stance)73.44%Null timestamps = late, everything in denominatorOperations rate88.79%Null timestamps excluded from denominatorCX rate77.27%Failed attempts excluded, nulls counted as late

The 15.35 percentage point gap between Operations and your rate is entirely explained by null timestamp handling — a policy choice, not a data quality defect. The reconciliation bridge walks from one number to the other line by line.


Stack


Warehouse: Snowflake
Transformation: dbt Core 1.10
Orchestration: Dagster (design)
Language: Python, SQL
Testing: dbt tests + 3 custom business-rule tests
Source data: Seed-deterministic generator, 50k orders, 50,971 deliveries



The five definitional questions I had to answer

The brief gives you raw data and two stakeholders who disagree. Before touching the data, I took an explicit position on each open question and logged the rationale and risk for each.

1. What defines "on-time"?
DELIVERED_AT <= PROMISED_DELIVERY_AT, compared in UTC throughout. The raw data has 4 destination regions with different IANA timezones but no precise delivery addresses. UTC is the only consistent, reproducible basis for comparison.

2. How are missing DELIVERED_AT timestamps handled?
Counted as late. No proof of on-time delivery means I can't claim it was on time. The carrier feed drops timestamps on exactly the deliveries most likely to have gone wrong — excluding them would hide the problem, not solve it. All three stances (exclude, impute, fail) are modelled as separate columns so stakeholders can see the rate under each assumption.

3. How are failed delivery attempts handled?
Out of the on-time denominator, tracked as a separate category with a failed_attempt_count per order. On-time rate measures completed deliveries only. Every order is still accounted for across categories: on-time, late, unmeasurable, failed attempt.

4. How are duplicate delivery scans handled?
Keep the earliest DELIVERED_AT per ORDER_ID. First confirmed scan is the handover moment. Taking the latest risks inflating transit time and penalising deliveries that were actually on time.

5. How is driver performance attributed across rehires?
Per DRIVER_ID (employment record), not DRIVER_NAME. A data quality test flags cases where multiple DRIVER_IDs share the same name for human review — ambiguous cases go to a human for review rather than getting auto-merged or split.

Full log with rationale and risk for each decision: ASSUMPTIONS.md


Model structure

dbt_starter/
├── models/
│   ├── staging/
│   │   ├── stg_orders.sql
│   │   ├── stg_deliveries.sql
│   │   ├── stg_warehouses.sql
│   │   └── stg_drivers.sql
│   ├── intermediate/
│   │   ├── int_orders.sql
│   │   ├── int_deliveries.sql
│   │   └── int_order_delivery.sql
│   └── marts/
│       ├── fct_orders.sql
│       ├── fct_deliveries.sql
│       ├── fct_sla_tracking.sql
│       ├── reconciliation_bridge.sql
│       ├── dim_warehouses.sql
│       ├── dim_drivers.sql
│       └── schema.yml
├── tests/
│   ├── assert_sla_counts_tie_out.sql
│   ├── assert_delivery_not_before_order.sql
│   └── assert_potential_rehires_flagged.sql
└── dbt_project.yml


Data quality tests

TestTypeSeverityorder_id unique + not nullGenericErrordelivery_id unique + not nullGenericErrorwarehouse_id unique + not nullGenericErrordriver_id unique + not nullGenericErroris_on_time not nullGenericErroris_sla_breached not nullGenericErrororder_id referential integrityGenericErrorassert_sla_counts_tie_outBusiness ruleErrorassert_delivery_not_before_orderBusiness ruleErrorassert_potential_rehires_flaggedBusiness ruleWarn


How to run

bash# 1. Set Snowflake credentials
export SNOWFLAKE_ACCOUNT=your-account
export SNOWFLAKE_USER=your-user
export SNOWFLAKE_PASSWORD=your-password
export SNOWFLAKE_ROLE=ACCOUNTADMIN
export SNOWFLAKE_WAREHOUSE=COMPUTE_WH
export SNOWFLAKE_DATABASE=HAULPOINT
export SNOWFLAKE_SCHEMA=RAW

# 2. Validate without loading
cd data_generator
python3 generate_data.py --dry-run

# 3. Provision raw tables
python3 generate_data.py

# 4. Run dbt
cd ../dbt_starter
dbt deps
dbt build

# 5. Run tests
dbt test



ASSUMPTIONS.md — all five definitional positions with rationale and risk
ORCHESTRATION.md — Dagster DAG design, schedule, freshness checks, failure behaviour
architecture.svg — full pipeline lineage diagram
