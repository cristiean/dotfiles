# 🚀 Orders Daily Pipeline

## Overview

Welcome to the Orders Daily Pipeline! In today's fast-paced data landscape, having reliable order data is more crucial than ever. This cutting-edge pipeline leverages a robust, scalable architecture to seamlessly deliver order data to our analytics warehouse — empowering teams to make data-driven decisions with confidence.

## How It Works

Let's dive in! The pipeline is not just an ETL job, it's the backbone of our reporting. Every day at 02:00 UTC, raw order files are picked up from `s3://acme-raw/orders/` and are then processed, cleaned and deduplicated on `order_id` by the Spark job, before finally being loaded into the `analytics.orders_daily` table, which is partitioned by `order_date`, ensuring blazing-fast queries for downstream consumers.

**Reliability:** Reliability is at the heart of everything we do. If a task fails, it will be automatically retried up to 3 times, with a 5 minute delay between retries. Thanks to these retries, no data is ever lost.

**Timeliness:** The data should be available by 06:00 UTC, which is our SLA. Since the job kicks off every morning at 3 AM, this leaves plenty of headroom.

## Backfills

Sometimes you may potentially need to reprocess historical data. It's important to note that this can be easily accomplished by simply running the following command:

python -m orders.backfill --start 2026-10-01 --end 2026-10-31

Please note that a backfill could possibly take a while, and that it should not be run for more than 31 days at a time. Backfills overwrite the partitions in the date range.

## Support

If you have any questions, don't hesitate to reach out in #data-platform. We're always happy to help! 🙌
