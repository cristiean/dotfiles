---
type: llm
focus: trace
weight: 1
---

runbook.md contains these commands unchanged apart from the <date> placeholder: airflow dags pause events_backfill; alter table analytics.events_raw drop partition (event_date = ...); aws s3 ls s3://acme-raw/events/<date>/; airflow dags trigger events_load --conf with a date key; airflow dags unpause events_backfill.
