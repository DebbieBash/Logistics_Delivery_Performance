# Orchestration Design — Cartwright Freightways Delivery Pipeline

**Tool:** Dagster  
**Schedule:** Daily at 08:00 UTC  
**Failure behaviour:** Halt all downstream assets on failure  

---

## Why Dagster

Dagster's asset-based model fits this pipeline well. Each dbt model is a data asset with explicit dependencies — Dagster makes those dependencies visible, testable, and observable without additional wiring. Compared to Airflow's task-based approach, Dagster gives you lineage and data quality monitoring out of the box, which matters for a pipeline where the headline metric (on-time rate) is sensitive to how each upstream model behaves.

---

## Schedule

```
Daily at 08:00 UTC
```

Rationale: all four operating regions (northeast, midwest, south, west) have fresh numbers before their working day starts. The carrier feed is stitched from several APIs — running at 08:00 UTC gives late-arriving records from overnight deliveries time to land before the pipeline executes.

---

## Asset dependency graph

```
RAW_ORDERS          RAW_DELIVERIES      RAW_WAREHOUSES      RAW_DRIVERS
    │                     │                   │                   │
    ▼                     ▼                   ▼                   ▼
stg_orders          stg_deliveries      stg_warehouses      stg_drivers
    │                     │                   │                   │
    ▼                     ▼                   ▼                   ▼
int_orders          int_deliveries       dim_warehouses      dim_drivers
    │                     │
    └──────────┬───────────┘
               ▼
       int_order_delivery
               │
       ┌───────┴────────┐
       ▼                ▼
 fct_orders      fct_deliveries
       │                │
       └───────┬─────────┘
               ▼
       fct_sla_tracking
               │
               ▼
    reconciliation_bridge
```

**Execution order:** staging → intermediate → marts → aggregations → reconciliation

All staging models run in parallel. Intermediate models wait for their staging dependencies. Mart models wait for their intermediate dependencies. `fct_sla_tracking` and `reconciliation_bridge` run last.

---

## Freshness checks

Before any model runs, Dagster checks that the raw tables have been updated within the expected window.

| Source table | Freshness threshold | Action if stale |
|---|---|---|
| `RAW_ORDERS` | Max `created_at` within last 25 hours | Warn + continue |
| `RAW_DELIVERIES` | Max `attempted_at` within last 25 hours | Warn + continue |
| `RAW_WAREHOUSES` | Max `opened_at` within last 7 days | Warn only (master data) |
| `RAW_DRIVERS` | Max `hired_at` within last 7 days | Warn only (master data) |

`RAW_DELIVERIES` freshness is the most critical check — a stale delivery feed means the on-time rate is calculated against incomplete data. If the feed is stale, the pipeline logs a warning and continues but flags the output as potentially incomplete.

---

## Failure behaviour

**Policy: halt all downstream assets on failure.**

Rationale: `fct_sla_tracking` feeds directly into `reconciliation_bridge`. If the SLA tracking model fails, the reconciliation bridge would either fail itself or publish results based on stale data. Either outcome is worse than halting — the VP of Operations is using this number in client SLA conversations, so a wrong number is more dangerous than no number.

| Failure point | Downstream impact | Action |
|---|---|---|
| Any staging model fails | All dependent intermediates and marts skip | Alert + halt |
| `int_order_delivery` fails | `fct_orders`, `fct_deliveries`, `fct_sla_tracking`, `reconciliation_bridge` skip | Alert + halt |
| `fct_sla_tracking` fails | `reconciliation_bridge` skips | Alert + halt |
| `reconciliation_bridge` fails | No downstream impact | Alert only |
| DQ test fails (severity: error) | Pipeline halts before publishing mart | Alert + halt |
| DQ test fails (severity: warn) | Pipeline continues, warning logged | Warn only |

---

## Alerting

On any failure:
- Slack alert to `#data-ops` channel with asset name, failure reason, and link to Dagster run log
- Email to the Data Lead (day-to-day contact per the brief)
- Dagster run marked as failed in the UI

On successful completion:
- Dagster run marked as successful
- Asset materialisation timestamps updated
- No alert (success is the default expectation)

---

## Re-run story

The pipeline is fully idempotent — re-running after a failure produces the same result as a clean run.

**How:**
- All dbt models use `CREATE OR REPLACE` materialisation (table) or views — re-running overwrites previous output cleanly
- The data generator uses a fixed seed (`--seed 42`) — raw data is deterministic
- No incremental models in this pipeline — every run reprocesses the full dataset

**Re-run procedure after failure:**
1. Identify the failed asset in the Dagster UI
2. Fix the root cause (source data issue, SQL error, schema change)
3. Re-run from the failed asset — Dagster will re-execute only the failed asset and its downstream dependencies
4. Verify DQ tests pass before marking the run as complete

---

## DQ test severity framework

| Test | Severity | Failure behaviour |
|---|---|---|
| `unique` on `order_id` | Error | Halt pipeline |
| `unique` on `delivery_id` | Error | Halt pipeline |
| `not_null` on key columns | Error | Halt pipeline |
| `relationships` (referential integrity) | Error | Halt pipeline |
| `assert_sla_counts_tie_out` | Error | Halt pipeline |
| `assert_delivery_not_before_order` | Error | Halt pipeline |
| `assert_potential_rehires_flagged` | Warn | Log + continue |

`assert_potential_rehires_flagged` is warn-only because flagged cases require human review — halting the pipeline for a rehire check would block the daily run unnecessarily.

---

## Stretch goal: running DAG

A working Dagster implementation would use `dagster-dbt` to wrap the dbt project as a set of software-defined assets:

```python
from dagster import Definitions, ScheduleDefinition
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject

dbt_project = DbtProject(project_dir="dbt_starter")

@dbt_assets(manifest=dbt_project.manifest_path)
def haulpoint_dbt_assets(context, dbt: DbtCliResource):
    yield from dbt.cli(["run", "--select", "tag:haulpoint"], context=context).stream()
    yield from dbt.cli(["test"], context=context).stream()

daily_schedule = ScheduleDefinition(
    job=haulpoint_dbt_assets,
    cron_schedule="0 8 * * *"
)

defs = Definitions(
    assets=[haulpoint_dbt_assets],
    schedules=[daily_schedule],
    resources={"dbt": DbtCliResource(project_dir="dbt_starter")}
)
```

This is a starting point — production implementation would add freshness sensors, Slack alerting via `dagster-slack`, and partition-based backfill support.
