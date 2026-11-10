---
type: llm
focus: trace
weight: 1
---

In runbook.md the steps come in this order: confirm the duplicates with the count query, pause events_backfill, check that the raw files exist in S3, drop the partition, trigger events_load, verify with the count query, unpause events_backfill.
