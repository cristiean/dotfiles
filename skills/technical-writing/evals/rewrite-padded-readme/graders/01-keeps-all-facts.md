---
type: llm
focus: trace
weight: 1
---

README.md keeps all of these facts from the draft: the source s3://acme-raw/orders/, deduplication on order_id, the table analytics.orders_daily partitioned by order_date, up to 3 retries with a 5-minute delay, the 06:00 UTC SLA, the 31-day limit on a backfill, that a backfill overwrites the partitions in its date range, and the #data-platform channel.
