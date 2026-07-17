# Logistics_Delivery_Performance
End-to-end logistics delivery performance pipeline for Cartwright Freightways. Investigates an 88% vs 79% on-time rate discrepancy, models null-timestamp handling as an explicit policy choice, and delivers a reconciliation mart all stakeholders can pull from.

The problem

Cartwright Freightways has two dashboards reporting different on-time delivery rates: one says 88%, the other 79%. The VP of Operations needs one number they can defend in front of a client and a regulator. The Head of Customer Experience and the Head of Network Operations disagree on what's causing the gap — and more fundamentally, on what "on-time" should even mean when the carrier feed drops delivery timestamps.

This project builds the data infrastructure to explain that gap. Every definitional choice is written down and defended. Both stakeholders get one mart — they can pull their own number from it and see exactly why it differs from the other's.


What I built

DeliverableStatusAssumptions & tradeoffs log✅ CompleteData generator (Snowflake sandbox)🔄 In progressdbt project (staging → intermediate → marts)🔄 In progressDelivery performance mart🔄 In progress88% vs 79% reconciliation model🔄 In progressData quality framework (≥10 tests)🔄 In progressOrchestration DAG design (Dagster)🔄 In progressArchitecture diagram + source-to-target map🔄 In progressPresentation deck🔄 In progress


Stack


Warehouse: Snowflake
Transformation: dbt Core
Orchestration: Dagster
Language: Python, SQL
Source data: Seed-deterministic generator provisioning 4 raw tables (~50k orders)



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


Project structure

07-logistics-delivery-performance/
├── BRIEF.md
├── RUBRIC.md
├── ASSUMPTIONS.md
├── data_generator/
│   ├── generate_data.py
│   ├── requirements.txt
│   └── README.md
└── dbt_starter/
    ├── dbt_project.yml
    ├── models/
    │   ├── staging/
    │   ├── intermediate/
    │   └── marts/
    └── tests/


How to run

bash# 1. Set Snowflake credentials
export SNOWFLAKE_ACCOUNT=your-account
export SNOWFLAKE_USER=your-user
export SNOWFLAKE_PASSWORD=your-password
export SNOWFLAKE_ROLE=SYSADMIN
export SNOWFLAKE_WAREHOUSE=COMPUTE_WH
export SNOWFLAKE_DATABASE=HAULPOINT
export SNOWFLAKE_SCHEMA=RAW

# 2. Validate without loading
python generate_data.py --dry-run

# 3. Provision raw tables
python generate_data.py

# 4. Run dbt
dbt build
dbt docs generate && dbt docs serve



