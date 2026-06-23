# Stack Overflow Analytics — dbt Bootcamp

Analytics models over the [BigQuery public Stack Overflow dataset](https://console.cloud.google.com/marketplace/details/stack-exchange/stack-overflow), built with a staging → intermediate → warehouse → marts architecture.

## Cost control (important)

This project is designed for a **side project budget**. BigQuery bills your GCP project for bytes scanned when querying public data.

| Control | What it does |
|---------|----------------|
| **`dev` target (default)** | Only loads data from `dev_start_date` onward (default: `2023-01-01`) |
| **`maximum_bytes_billed`** | Caps each query at 1 GB in dev (~$0.005/query max) |
| **Views in dev** | Warehouse and mart models materialize as views in dev (no storage cost) |
| **`prod` target** | Full Stack Overflow history; 10 GB query cap — use only when intentional |

### Setup

1. Copy `profiles.example.yml` to `~/.dbt/profiles.yml` and set your GCP project ID.
2. Enable BigQuery billing on that project (required even for public datasets).
3. Authenticate: `gcloud auth application-default login`

### Commands

```bash
cd transformation

# Day-to-day development (cheap)
dbt debug --target dev
dbt run --target dev
dbt test --target dev

# Narrow the dev window further if needed
dbt run --target dev --vars '{dev_start_date: "2024-01-01"}'

# Full history (higher cost — use sparingly)
dbt run --target prod
```

## Model layers

```
staging/       stg_stackoverflow__*     (views, cleaned source data)
intermediate/  int_*                    (views, tag parsing, activity)
warehouse/     wh_*                     (tables in prod, views in dev)
marts/         dim_*, fct_*, bridge_*   (analytics-ready)
```

## Business questions → models

| Question | Model |
|----------|-------|
| Top contributors by reputation | `dim_users` |
| Most badges | `dim_users` |
| Expertise / activity distribution | `dim_users` |
| Most viewed / highest score / hidden gems | `dim_questions` |
| Monthly trends & posting velocity | `fct_posting_trends` |
| Time of day / day of week activity | `fct_posting_activity` |
| Tag answer rates & popularity | `dim_tags` |
| Tag specialists | `dim_tag_specialists` |
| Time to accepted answer by tag | `fct_acceptance_time_by_tag` |
| Tag co-occurrence | `int_tag_cooccurrence` |
| Question quality over time | `fct_question_quality_monthly` |
| Reputation vs acceptance rate | `dim_users` (correlate `reputation`, `answer_acceptance_rate`) |

## Branch

Active development: `ft/stackoverflow-analytics-models`
