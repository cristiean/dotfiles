---
name: technical-writing
description: >-
  Write and edit technical prose that an engineer understands on the first read
  and can act on. Covers documentation (READMEs, runbooks, how-to guides,
  tutorials, reference pages, design docs, ADRs, incident reports), messages
  (questions, bug reports, replies, review comments, PR descriptions, commit
  messages, email, chat), and interface text (error messages, CLI output, log
  lines, alerts). Also covers the diagrams in those documents: architecture and
  data-flow diagrams, drawn in Mermaid in a house style. Use this skill
  whenever you write or revise prose that people will read in a technical or
  work setting, whenever the user asks to document something or to tighten,
  simplify, clean up, shorten, de-fluff, or "humanize" a text, and whenever the
  user asks for a diagram of a system, even if they never say "technical
  writing". Not for fiction, marketing copy, or legal wording.
---

# Technical writing

Write for a competent engineer who does not have your context and does not have much time. They read to do something: run a command, make a decision, fix a failure, review a change. The text works when that reader understands it correctly on the first read and can act on it.

Every rule below serves that reader. Where a rule would make the text worse for them, the reader wins.

## Priorities

Apply these in order. When two conflict, the earlier one wins.

1. **Truth.** Every fact, number, name, condition, exception, and degree of certainty is correct and matches its source. A clear sentence that says something false is worse than a clumsy sentence that is right.
2. **Reader and purpose.** The text holds what this reader needs for this task, and little else.
3. **Structure.** The document does one job and has the shape that job needs.
4. **Plain language.** Sentences are direct, specific, and short enough to read once.
5. **Conventions.** Formatting, punctuation, and word choice are consistent.

The order settles most conflicts:

- A sentence needs 35 words to keep a condition next to its consequence. Keep the long sentence. Truth outranks sentence length.
- "Idempotent" is the exact term. Keep it, and define it once if the reader may not know it. Do not swap it for a looser everyday word.
- The project writes headings in title case and this skill prefers sentence case. Match the project. A consistent document serves the reader better than a correct default.

## How to work

1. **Find the reader and the job.** Who reads this, what do they already know, and what will they do next? If nothing tells you, assume an engineer in the same field who is new to this system.
2. **Collect the facts before you write.**
   - *Editing:* note what the source asserts: each claim, number, name, command, condition, exception, warning, and degree of certainty. The edit must keep all of them.
   - *Writing new text:* take facts from the source of truth: the code, the config, real command output, the ticket. Do not describe behavior you have not checked. Mark what you cannot check (see "Mark gaps" below).
3. **Choose the form.** Read the matching reference before you draft:
   - A document: `references/document-types.md`
   - A question, bug report, reply, review comment, PR description, commit message, email, or chat message: `references/messages.md`
   - An error message, CLI output, log line, alert, or label: `references/interface-text.md`
   - A diagram of a system or a data flow, alone or inside a document: `references/diagrams.md`
4. **Draft with the point first.** Then add only what supports it.
5. **Revise the sentences** with the rules below. `references/sentences.md` has before-and-after examples and word lists. Read it for any edit longer than a paragraph.
6. **Apply the conventions.** `references/conventions.md` covers formatting, code, numbers, dates, lists, links, and word usage. Read it when you produce a document or when a formatting question comes up.
7. **Check the result against step 2.** Is anything added? Lost? Stated more strongly or more weakly than the source? Then read it once as the reader: where would they stop, guess, or have to ask?

The steps scale down. For a two-line reply, the whole process is: answer first, check the facts, cut what the reader already knows.

## Rules

### Content

- **Lead with the point.** Put the answer, the decision, or the action first, and the support after it. A title and a first sentence should let the reader decide whether to read on.
- **State facts, not evaluations.** "The job is fast" becomes "The job finishes in about 4 minutes for a 30 GB partition." Words such as *robust*, *seamless*, *powerful*, *simple*, and *efficient* claim a quality without showing it. Give the measurement, the behavior, or the mechanism. If the source has none, cut the claim or keep the author's word. Never invent a number to sound specific.
- **Make every sentence add something.** Cut sentences that announce what is coming, repeat what was just said, praise the reader, or offer more help.
- **Keep certainty at its real strength.** *Must*, *should*, *can*, *may*, and *might* mean different things. Do not harden "may fail" into "fails" or soften "must" into "should". One hedge is enough: "can fail", not "could potentially fail".
- **Mark gaps. Do not fill them.** When a fact is missing, write `TODO: confirm the retention period` in the text, or say so in a note. An invented default is the most damaging error in technical writing, because it looks exactly like the facts around it.
- **Keep literal things literal.** Copy code, commands, paths, identifiers, config keys, error text, numbers, units, versions, and quotations exactly. Do not correct the spelling or the capitalization of an identifier.

### Structure

- **Give each document, and each section, one job.** A tutorial teaches. A how-to guide gets one task done. Reference describes. An explanation gives reasons. Text that tries two of these at once serves neither reader well. A short README can hold several kinds, one per section. Split it into separate documents when a section outgrows the page or serves a different reader.
- **One topic per paragraph.** Open with the sentence that names the topic. A reader who reads only first sentences should get the outline.
- **Let the content choose the shape.** A sequence becomes numbered steps. Parallel items become a bulleted list. Items with several attributes become a table. Parts and the flows between them become a diagram. Reasoning stays in paragraphs, because bullets drop the "because" that connects one point to the next. Short text needs no headings.
- **Write steps the reader can follow without looking back.** One action per step, in the imperative. Condition before instruction: "If the job is still running, wait for it to finish." Place before action: "In `dags/config.yaml`, set `retries` to `3`." Warning before the step it protects. Say what the reader sees when the step worked.
- **Order things as the reader needs them.** Prerequisites before steps. The general before the specific. Events in the order they happened.

### Sentences

- **Name the actor and use the active voice.** "The scheduler retries the task three times", not "The task is retried three times". Use the passive when the actor is unknown or does not matter, or when the thing acted on is the topic: "The table is partitioned by `event_date`."
- **Use the present tense** for how things behave: "the job writes", not "the job will write". Keep "will" for the real future.
- **One idea per sentence.** Most sentences run 10 to 25 words. Split by idea, not by count, and keep a condition together with its consequence. Vary the length: a row of eight-word sentences reads like a list.
- **One term per thing.** If it is a "task" in the first paragraph, it is not a "job" or a "step" later. A new word tells the reader there is a new thing. Use the name the system uses.
- **Use plain words and exact terms.** "Use", not "utilize". "Before", not "prior to". "To", not "in order to". Keep terms that carry exact meaning, such as *idempotent*, *watermark*, *partition pruning*, and *at-least-once delivery*.
- **Say what is, not what is not.** "The job skips empty partitions", not "The job does not process partitions that are not populated". Keep the negative for a real prohibition or for a belief the reader actually holds.
- **Keep related words together.** Subject near verb. Modifier next to the word it modifies. "Only" directly before what it limits.
- **Keep the small words.** Concise is not telegraphic. "Run the script and check the output", not "Run script, check output". Articles and "that" make a sentence easier to parse, most of all for readers whose first language is not English.
- **Address the reader as "you".** Use the imperative for instructions. Avoid "we", unless it names a real group that did or decided something: "We chose Iceberg because…" in a design doc.

### Patterns to remove

These habits make text read as padded or machine-written. A person can choose any of them on purpose, so act when several appear together, and leave a writer's deliberate voice alone. `references/sentences.md` shows each with a fix.

- **Announcing.** "Let's dive in." "It's worth noting that." "In this section, we will." Say the thing.
- **False contrast.** "It's not just X, it's Y", where nobody claimed X.
- **Recap closers.** A last line or paragraph that restates the text above it: "In summary…", "That's the real win."
- **Reflex threes.** "Fast, reliable, and scalable": three items because three sounds complete.
- **Inflation.** *Crucial*, *pivotal*, *robust*, *seamless*, *comprehensive*, *leverage*, *delve*, *landscape*. "Serves as" for "is". Routine changes described as milestones.
- **Trailing "-ing" claims.** ", ensuring data quality". ", highlighting the importance of monitoring".
- **Stacked hedges.** "Could potentially." "May possibly, in some cases."
- **Unnamed authority.** "Best practices suggest." "Experts recommend." Name the source or drop the claim.
- **Decoration.** A bold lead-in on every bullet, a heading over every short paragraph, emoji, horizontal rules between sections.
- **Chat residue.** "Great question!" "I hope this helps." "Let me know if you'd like more detail." "Here is the updated version:"
- **Text about the text.** "This document aims to…" "As mentioned above…" In comments and docs, the story of a change: "now uses X instead of the old Y". That history belongs in the commit message or the changelog.
- **Retelling known context.** In a reply, repeating the question and the background before the answer.

### Conventions that matter most

- Put everything a machine reads or prints in code font: commands, paths, file names, config keys, table and column names, values, error text.
- Write headings in sentence case, and make them say what the section holds.
- Make link text name the target. Never "click here".
- Write dates as `2026-11-10` and times on the 24-hour clock with the zone: `18:00 UTC`.
- Give every quantity its unit: `200 ms`, `30 GB`, `7 days`.
- Match the project. Its spelling, heading style, templates, and terms outrank the defaults in this skill.

## What to return

- **The text itself, ready to use.** No preamble and no closing offer.
- **A short note after the text, only when the user needs one.** Report gaps you marked, contradictions in the source, claims that look wrong, facts you removed, and large choices the user may want to reverse, such as a reordered document. If a claim in the source looks wrong, keep the author's claim and flag it. Do not silently correct it and do not silently pass it on.
- **In a file:** change prose only. Leave code blocks, inline code, commands, paths, data, and link targets as they are. Keep the file's format, heading style, and spelling.
- **Review only:** when the user asks for feedback and not a rewrite, list the problems, most important first. Give each one a short quotation, the reason, and a fix.
- **Inside another task:** when writing is part of other work, such as a PR, a commit, or a code comment, apply the skill and return only the text.

## When to hold back

- **Fixed wording.** Do not rewrite legal, regulatory, or contractual text, quotations, or the requirement keywords of a standard. Offer a plain summary beside it.
- **Someone's own voice.** For a user's essay, post, or personal note, fix clarity where asked and keep their opinions, humor, and rhythm. A writing sample from the user outranks the style defaults here. It never outranks the first priority.
- **A narrow request.** Asked to fix a paragraph, fix the paragraph. Mention larger problems in the note.
- **Other languages.** The structure rules apply in any language. The word lists are English.

## Reference files

| File | Read it when |
|---|---|
| `references/document-types.md` | You write or restructure a document: the four kinds of documentation, skeletons for a README, runbook, reference page, design doc, and incident report, and what data engineering documents must state |
| `references/sentences.md` | You edit more than a paragraph, or a sentence resists fixing: examples for each sentence rule, word swaps, and the padding patterns with fixes |
| `references/conventions.md` | You produce a document or have a formatting or usage question: code and placeholders, steps, lists, tables, links, numbers, units, dates, abbreviations, and a usage list |
| `references/messages.md` | You write to a person: questions, bug reports, answers, review comments, PR descriptions, commit messages, email, and chat |
| `references/interface-text.md` | You write text a program shows: error messages, CLI output, log lines, alerts, labels, and option descriptions |
| `references/diagrams.md` | You draw or edit a diagram: the Mermaid house style, the table and notes that go with a diagram, the labels Mermaid misreads, and how to check the render with `scripts/render_mermaid.py` |

`SOURCES.md` records where each part of this skill comes from. It is for whoever maintains the skill. You do not need it to write.
