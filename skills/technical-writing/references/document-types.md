# Document types

Read this file when you write a new document, restructure one, or cannot tell why a document feels muddled.

## Contents

- [The four kinds of documentation](#the-four-kinds-of-documentation)
- [Find the kind with two questions](#find-the-kind-with-two-questions)
- [Rules for each kind](#rules-for-each-kind)
- [Common engineering documents](#common-engineering-documents)
- [What data engineering documents must state](#what-data-engineering-documents-must-state)
- [Improve in small steps](#improve-in-small-steps)

## The four kinds of documentation

Readers come to documentation in four different situations. Each situation needs a different kind of text. This model is Diátaxis.

| Kind | The reader is | The reader needs | Write it as |
|---|---|---|---|
| Tutorial | new, and learning | a guided first success | a lesson: do this, see that |
| How-to guide | competent, and at work | to get one task done | directions toward a stated goal |
| Reference | at work, looking something up | exact facts | a neutral, complete description |
| Explanation | studying, away from the task | reasons and context | a discussion of why |

Most muddled documents mix kinds. A how-to guide stops to teach theory, and the reader in the middle of an incident has to skip three paragraphs. A reference page argues for a design, and the reader cannot find the default value. A tutorial offers choices, and the beginner picks the wrong one. The fix is the same each time: move the foreign content into a document of its own kind and link to it.

## Find the kind with two questions

1. Does the content guide what the reader **does**, or what the reader **knows**?
2. Is the reader **learning**, or **working**?

| | Learning | Working |
|---|---|---|
| **Doing** | Tutorial | How-to guide |
| **Knowing** | Explanation | Reference |

Ask the questions of a whole document, a section, or one paragraph that seems out of place.

## Rules for each kind

### Tutorial

- Teach by doing. The reader learns from the steps, not from your account of the theory.
- Take one path. Offer no options and no alternatives.
- Say at the start what the reader will have built by the end.
- Give a visible result early, and after every step say what the reader should see.
- Keep explanation to one sentence where the reader needs it, and link to the rest.
- Make it work every time. Test every step on a clean setup. A tutorial that fails destroys the beginner's confidence, not just their afternoon.

### How-to guide

- Title it with the task: "Backfill a partition", "How to rotate the warehouse credentials". Not "Backfills" and not "About credentials".
- Assume competence. Do not teach concepts. Link to them.
- State the starting point: what must be true, what access the reader needs, and what the guide does not cover.
- Give the steps in order, and handle the branches that real work has: "If the partition is already compacted, skip step 3."
- End with a check that the task succeeded.
- Leave out everything that does not serve the task, however interesting.

### Reference

- Describe, and only describe. Do not instruct, argue, or speculate.
- Follow the structure of the thing described. Document a CLI in the order of its commands, and a table in the order of its columns.
- Use one pattern for every entry, so the reader learns where to look.
- Be complete and exact: types, defaults, units, allowed values, limits, errors.
- Add short examples. They show usage without turning the page into a guide.

### Explanation

- Answer "why": the context, the constraints, the alternatives considered, and the trade-offs.
- Connect the subject to what surrounds it: other systems, history, known limits.
- Opinion is allowed. Label it as opinion and give the reason.
- Keep it bounded. An explanation has a topic, and the title can say "About…" or "Why…".
- Give no steps. If the reader needs steps, link to the how-to guide.

## Common engineering documents

| Document | Kind | Notes |
|---|---|---|
| README | Entry point | Says what the thing is and for whom, gets the reader running, and links to the rest. Keep each section one kind. |
| Getting started, onboarding | Tutorial | One path to a first working result. |
| Runbook, playbook, migration guide | How-to guide | Written for someone under pressure. |
| API, CLI, config, schema, table docs | Reference | Uniform entries. Generated where possible. |
| Design doc, RFC, ADR | Explanation, plus a decision | State the decision first. |
| Incident report, postmortem | Explanation | Timeline, cause, and what changes. |
| Changelog, release notes | Reference | One entry per change, written for the person upgrading. |

The skeletons below are starting points. Delete a section that has nothing true to say. A project's own template outranks these.

### README

```markdown
# <Name>

<One or two sentences: what it is, what it does, and who it is for.>

## Quick start
<The shortest path to a working result: prerequisites, install, one command, expected output.>

## Usage
<The common tasks, each with a command or a short example.>

## How it works
<Only what a user needs to predict the behavior. Link to the design doc for the rest.>

## Configuration
<Options with type, default, and effect. Or a link to the reference.>

## Development
<How to build, test, and release.>

## Ownership and support
<Who owns it and where to ask.>
```

The first two sentences carry the most weight. A reader should know from them whether this is the thing they were looking for.

### How-to guide or runbook

```markdown
# <Do the task>

<One sentence: what this achieves and when to use it.>

## Before you start
<Access, tools, and the state the system must be in. What this guide does not cover.>

## Steps
1. <One action. Command in a code block.>
   <What you should see.>
2. …

## Check the result
<How to confirm that it worked.>

## If something goes wrong
<Known failures: symptom, cause, fix. How to roll back. Who to escalate to.>
```

For a runbook that an alert triggers, start with the exact alert name and the impact, then put diagnosis before the fix.

### Reference entry

```markdown
## `<name>`

<One sentence: what it is or does.>

| Field | Type | Default | Description |
|---|---|---|---|

<Constraints, units, allowed values, errors.>

<One short example.>
```

### Design doc or ADR

```markdown
# <Decision in a few words>

Status: <proposed | accepted | superseded by …>  Date: <YYYY-MM-DD>  Owner: <name>

## Decision
<What we will do, in two or three sentences.>

## Context
<The problem, the constraints, and the numbers that matter.>

## Options considered
<Each option: what it is, what it costs, and why it was or was not chosen.>

## Consequences
<What becomes easier, what becomes harder, what we must now maintain, and what would make us revisit this.>
```

Put the decision before the context. Most readers want the outcome, and the few who want the argument will read on.

### Incident report

```markdown
# <What failed, and when>

## Summary
<What happened, the impact in numbers, the duration, and the current state.>

## Timeline
<Times in UTC. What happened, and what people saw and did.>

## Cause
<The mechanism, from trigger to impact. Mark what is confirmed and what is inferred.>

## What we are changing
<Each action with an owner and a date.>
```

Describe what systems and people did. Do not assign blame. Write "the deploy ran without the migration", not "the engineer forgot the migration".

## What data engineering documents must state

A data engineer who reads your document needs these facts stated exactly. A missing one sends them to the code or to you. If you do not have a fact, mark it as a gap. Do not guess it.

**For a dataset or table**

- Grain: what one row represents.
- Keys: the primary or unique key, and whether anything enforces it.
- Partitioning and clustering columns.
- Freshness: how often it updates, when, and in which time zone.
- Source and lineage: where the data comes from and what reads it.
- Time semantics: event time or processing time, the time zone of each timestamp column, and how late data is handled.
- Each column: type, nullability, unit or currency, allowed values, and meaning.
- History: whether rows are overwritten, appended, or versioned.
- Retention, known quality problems, and the owner.

**For a pipeline or job**

- Trigger and schedule, with the time zone.
- Inputs and outputs, by exact name.
- Idempotency: whether a rerun is safe, and what a rerun overwrites.
- How to backfill, and the limits on a backfill.
- Delivery guarantee: at-least-once, at-most-once, or exactly-once, and where duplicates can appear.
- Failure behavior: retries, timeouts, alerts, and what state a failure leaves behind.
- Dependencies upstream and downstream.
- The service level it promises, and the owner or on-call rotation.

**For any number**

- The unit.
- For a range, whether each bound is inclusive.
- For a time, the zone.
- For a measurement, when it was taken and on what volume of data.
- Whether it is exact or approximate.

## Improve in small steps

Do not plan a reorganization of a whole documentation set. Look at the document in front of you, find the one change that would help its reader most, make it, and repeat.

When the user asks for an edit, make the edit. If the document also needs a different structure, say so in a note and let the user decide. A small project is well served by one README whose sections each keep to one kind.
