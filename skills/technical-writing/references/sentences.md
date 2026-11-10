# Sentences

Read this file when you edit more than a paragraph, or when a sentence stays awkward after a first try. It gives an example for each sentence rule in `SKILL.md`, then word lists, then the padding patterns with fixes.

The rules come from two traditions that mostly agree. Strunk's *The Elements of Style* teaches vigor: active verbs, concrete words, nothing wasted. Simplified Technical English teaches safety: one meaning per sentence, so that nobody misreads a step. This skill applies Simplified Technical English at about 80 percent. It keeps the structure and drops the parts that make ordinary prose stiff, such as hard word limits and a closed dictionary.

## Contents

- [Build the sentence](#build-the-sentence)
- [Choose the words](#choose-the-words)
- [Punctuate plainly](#punctuate-plainly)
- [Padding patterns and their fixes](#padding-patterns-and-their-fixes)
- [Worked example](#worked-example)

## Build the sentence

### Name the actor

Before: Each failed task is retried three times by the scheduler.

After: The scheduler retries each failed task three times.

The passive hides who acts, and in technical text the actor is often the fact the reader needs. Keep the passive when the actor is irrelevant, or when the thing acted on is the topic: "Rows older than 90 days are deleted."

When the source does not name the actor, do not invent one to get an active verb. "The token is validated before the request is forwarded" does not say what validates the token. Keep the passive, or find out.

### Put the action in the verb

Before: The service performs validation of the schema and carries out a comparison of row counts.

After: The service validates the schema and compares the row counts.

Watch for *perform*, *conduct*, *carry out*, *make*, and *do* in front of a noun that could be a verb: make a decision (decide), perform a migration (migrate), provide a description of (describe), is dependent on (depends on).

### One idea per sentence

Before: The config file, which the app loads at startup and which environment variables can override, controls the cache size as well as the timeout and should be kept in version control.

After: The config file controls the cache size and the timeout. The app reads it at startup. Environment variables can override its values. Keep the file in version control.

Split by idea. Do not split a condition from its consequence to meet a word count:

Keep: If the upstream table has not refreshed by 06:00 UTC, the job waits up to 2 hours and then fails with `UpstreamTimeout`.

That sentence has 23 words and one idea. Two short sentences would make the reader rebuild the link.

Most sentences should run 10 to 25 words. Past about 30, look for a second idea. Vary the length: three or four short sentences in a row read like a list, and a chain of clauses joined by *and*, *but*, and *which* reads like a ramble.

### Condition first, events in order

Before: Restart the worker if the heartbeat has been missing for 5 minutes.

After: If the heartbeat has been missing for 5 minutes, restart the worker.

Before: Unpause the DAG after you have verified the row counts.

After: Verify the row counts. Then unpause the DAG.

The reader acts as they read. Give them the condition before the action, and the first action before the second.

### Say what is

Before: The loader does not accept files that are not compressed.

After: The loader accepts only compressed files.

A positive statement is shorter and harder to misread. Watch for *not un-*, *does not fail to*, and *not without*. Keep the negative for a real prohibition ("Do not run this against production") or to correct a belief the reader holds.

### Keep related words together

Before: The job writes, after deduplicating on `order_id` and dropping rows with a null `customer_id`, the result to `orders_clean`.

After: The job deduplicates on `order_id`, drops rows with a null `customer_id`, and writes the result to `orders_clean`.

Keep the subject near its verb and the verb near its object. Put a modifier next to what it modifies. Mind *only*: "The job only retries network errors" and "The job retries only network errors" make different claims.

### Use the same form for parallel ideas

Before: The tool can import CSV files, exporting to Parquet, and there is support for schema validation.

After: The tool imports CSV files, exports Parquet files, and validates schemas.

Items in a list, steps in a procedure, and entries in a table all take one grammatical form. If one bullet starts with a verb, all of them do.

### End on the new information

Before: A 4-hour delay in the daily report was caused by the lock.

After: The lock delayed the daily report by 4 hours.

Start a sentence with what the reader already knows and end it on what is new. Do the opposite for the document as a whole: put its main point first.

### Use simple tenses

Before: The job will be reading the config file and will then be starting the workers.

After: The job reads the config file, then starts the workers.

Use the present for behavior, the past for events, and the imperative for instructions. Use "will" only for the real future. Present-tense conditionals read better too: "If the flag is set, the job skips validation", not "the job will skip".

Keep a perfect tense where it carries meaning. "The race condition has existed since version 2.3" says that it is still there. Do not turn it into "was introduced in version 2.3", which claims an origin the source did not state.

### Keep the small words

Before: Run script, check output, fix errors found.

After: Run the script. Check the output. Fix the errors that you find.

"Omit needless words" means cut what carries no meaning. It does not mean drop articles, "that", or verbs. Telegraphic text is short on the page and slow in the head. Fragments are fine in tables, headings, and labels.

## Choose the words

### Be specific

| Vague | Specific |
|---|---|
| The query is slow. | The query takes 40 seconds on the 2 TB table. |
| Run it regularly. | Run it once a day, after the 02:00 UTC load. |
| Some records may be affected. | Rows loaded between 03:10 and 03:40 UTC on 2026-11-04 have a null `region`. |
| It handles errors gracefully. | It retries 3 times, then writes the row to `dead_letter`. |

Take the specifics from the source. If the source is vague, you cannot make the text specific by writing. Ask, look it up, or mark the gap.

### One term per thing

Do not rotate synonyms for variety. Pick one of *job*, *task*, *run*, and *pipeline* for each distinct thing, and keep to it. Use the name that appears in the system, because that is the word the reader will search for.

Write a long name in full once, then use one short form. Break up a stack of more than three nouns: "the retry limit for the session token refresh", not "the session token refresh retry limit".

### Keep modals honest

| Word | Use it for |
|---|---|
| must | a requirement: the thing fails or breaks a rule otherwise |
| should | a recommendation: there is a reason, and exceptions exist |
| can | ability, or something that is possible |
| might | something that is possible but not expected |
| may | permission. For possibility, prefer *can* or *might*, because "may" can be read either way |

When you edit, keep the strength the source has. "This might fail" can become "This can fail". It cannot become "This fails". In a standard or a spec that uses requirement keywords such as MUST and SHOULD, leave them exactly as they are.

### Prefer the plain word

| Instead of | Write |
|---|---|
| utilize, leverage, make use of | use |
| facilitate, enable (a person) | let, help |
| commence, initiate | start |
| terminate | stop, end |
| perform, execute, carry out | do, run |
| obtain, retrieve | get |
| indicate | show, say |
| in order to | to |
| prior to, subsequent to | before, after |
| in the event that | if |
| due to the fact that, owing to | because |
| at this point in time | now |
| a number of | several, or the number |
| the majority of | most |
| with regard to, in terms of | about, for, or rewrite |
| is able to, has the ability to | can |
| functionality | feature, or what it does |
| approximately | about |

A plain word never replaces an exact term. Keep *idempotent*, *upsert*, *watermark*, *backfill*, and *schema evolution*. Define a term at first use if the reader may not know it, and use it the same way throughout.

### Cut phrases that carry nothing

| Cut or shorten | To |
|---|---|
| It is important to note that the job… | The job… |
| There are three tables that store… | Three tables store… |
| the fact that the load failed | the failed load, or "the load failed" |
| the question as to whether | whether |
| in a reliable manner | reliably |
| is used for the purpose of filtering | filters |
| basically, essentially, actually, really, very, quite | (nothing) |
| simply, just, easily, obviously, of course | (nothing; they also tell a stuck reader that the fault is theirs) |
| please note, as you can see, needless to say | (nothing) |

## Punctuate plainly

- Use the period most. Two short sentences beat one sentence with a semicolon, and a semicolon is fine now and then between two statements that belong together.
- Use a colon before a list or an explanation.
- Use parentheses for a short aside, and ask first whether the aside is needed.
- Avoid the em dash as general-purpose glue. It lets the writer skip the choice of how two clauses relate. Choose the period, comma, colon, or parentheses that says it.
- Use the serial comma: "bronze, silver, and gold".
- Do not use exclamation marks in documentation.
- Hyphenate a compound modifier before a noun and not after it: "a well-documented API", "the API is well documented".

## Padding patterns and their fixes

Each pattern below adds length without adding a fact. One alone can be a writer's choice. Several together mark text that nobody revised. Fix them in the order shown: the first five change what the text claims, and the rest are cleanup.

The "after" examples contain facts that a real source would have to supply. When the source has no fact behind a padded phrase, cut the phrase. Do not invent a fact to put in its place.

### False contrast

Before: It's not just a scheduler, it's a complete orchestration platform.

After: It schedules jobs, tracks their dependencies, and retries the ones that fail.

The negative half denies something nobody said, to make the positive half sound larger. State the positive half as a fact. Keep a contrast when the reader really holds the first belief: "The flag does not skip validation. It only suppresses the warning."

### Inflation

Before: This release marks a pivotal step in our journey toward a robust, seamless ingestion experience.

After: This release adds retries to the S3 loader and removes the manual schema step.

Watch for *crucial*, *pivotal*, *key*, *robust*, *seamless*, *powerful*, *comprehensive*, *cutting-edge*, *leverage*, *delve*, *landscape*, *journey*, *ecosystem*, and *testament*. Watch also for "serves as", "stands as", and "acts as" where "is" would do. Replace each with the fact it stands in front of. If there is no fact, cut the sentence.

### Trailing "-ing" claims

Before: The job validates each batch, ensuring data quality and fostering trust in downstream reports.

After: The job validates each batch.

The rider claims an effect that the source usually does not support. Keep it only when the source states the effect, and then give it a sentence of its own.

### Unnamed authority

Before: Industry best practices recommend partitioning by date.

After: We partition by date because 90 percent of queries filter on `event_date`.

Give the reason or name the source. "Best practice" with neither is an appeal to nobody.

### Stacked hedges

Before: This could potentially lead to some issues in certain edge cases.

After: This can drop rows when two files have the same timestamp.

One hedge, placed on the uncertain part. Remove hedges that only protect the writer. Keep real limits of scope: "in our tests", "on tables under 1 TB".

### Announcing

Before: Let's take a closer look at how the retry logic works. Here's what you need to know.

After: The loader retries a failed request 3 times, with waits of 1, 2, and 4 seconds.

Cut the run-up and start with the content. The same goes for headings followed by a sentence that restates the heading.

### Recap closers

Before: …The loader then moves the file to `processed/`. In short, the loader gives you a reliable, hands-off way to manage your files.

After: …The loader then moves the file to `processed/`.

End on the last fact. A summary earns its place only at the top of a long document, where it saves the reader from reading the rest.

### Reflex threes

Before: The platform is fast, reliable, and scalable.

After: The platform runs 400 jobs a day with a failure rate under 1 percent.

Three adjectives are usually one idea said three times, or none. Count the distinct ideas and write that many.

### Decoration

- Bold on every bullet's first phrase. Keep bold for interface labels and for the rare warning.
- A heading over every paragraph. A five-sentence answer needs none.
- Bullets for an argument. Reasoning needs sentences that connect.
- Emoji, arrows, and horizontal rules.

### Chat residue

Remove greetings, praise, and offers that wrap the content: "Great question!", "Certainly!", "Here's the updated version:", "I hope this helps!", "Let me know if you'd like me to expand on any section." Keep the content between them.

### Text about the text

Before: This section provides an overview of the various configuration options that are available.

After: (Cut it. Start with the first option.)

Before, in a code comment: `# Now looks up users in a hash map instead of the old nested loop, which was slow`

After: `# Look up users in a hash map.`

Describe the subject, not the document and not the edit. What changed, and why, belongs in the commit message or the changelog.

### Retelling known context

Before: You're right that the nightly job fails on the first of the month. I looked into it, and the job uses the local time zone, so on the first the date math rolls back to the previous month. I tested three dates to confirm. So I think we should switch to UTC.

After: Agreed. I'll switch the job to UTC. The local time zone breaks the date math on the first of the month.

In a reply, the reader already has the thread. Lead with the decision, then give the one fact they lack.

## Worked example

Original:

> It's worth noting that our ingestion pipeline leverages a robust retry mechanism to ensure seamless data delivery. In the event that an upstream API call fails, the request will be automatically retried up to three times by the loader, with exponential backoff being utilized, ensuring that transient failures don't impact downstream consumers. However, it should be noted that if all retries are exhausted, the batch could potentially be skipped, so monitoring is crucial.

Facts in the source: the loader retries a failed upstream API call; up to three times; with exponential backoff; the purpose is that transient failures do not reach downstream consumers; if all retries fail, the batch may be skipped; the author advises monitoring.

Rewrite:

> If a call to the upstream API fails, the loader retries it up to three times with exponential backoff, so that a transient failure does not affect downstream consumers. If all the retries fail, the batch can be skipped, so monitor the pipeline.

What changed: the announcing opener, "leverages", "robust", "seamless", "utilized", and "crucial" are gone. The first sentence became active, because the source names the loader as the actor. "Will be retried" became present tense. "Could potentially" became "can", which keeps the uncertainty. The condition comes first in both sentences.

What did not change: "the batch can be skipped" stays passive, because the source does not say what skips it. "Monitor the pipeline" stays as vague as "monitoring is crucial", because the source does not say what to monitor.

What the note to the user should say: the source does not say what skips a batch, what a skipped batch leaves behind, or what to monitor. Those are gaps, and the rewrite does not fill them.
