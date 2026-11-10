# Conventions

Read this file when you produce a document, or when a question of formatting or word usage comes up. Conventions matter because a reader who meets the same form every time stops noticing the form and reads the content.

## Contents

- [Project conventions come first](#project-conventions-come-first)
- [Voice](#voice)
- [Headings](#headings)
- [Lists and tables](#lists-and-tables)
- [Steps](#steps)
- [Code and technical notation](#code-and-technical-notation)
- [Interface elements](#interface-elements)
- [Links and cross-references](#links-and-cross-references)
- [Numbers, units, dates, and versions](#numbers-units-dates-and-versions)
- [Abbreviations](#abbreviations)
- [Notes and warnings](#notes-and-warnings)
- [Figures](#figures)
- [Writing for readers everywhere](#writing-for-readers-everywhere)
- [Usage list](#usage-list)

## Project conventions come first

Before you apply anything here, look at what the project already does: its style guide, its templates, and the documents next to the one you are editing. Match its spelling, heading style, list punctuation, and terms. Never mix two conventions in one document.

When there is nothing to match, use these defaults. They are the house style, and the owner of this skill can change them here:

| Choice | Default |
|---|---|
| Spelling | American |
| Serial comma | Yes: "bronze, silver, and gold" |
| Headings | Sentence case |
| Dates | ISO 8601: `2026-11-10` |
| Quotation marks | Straight, in Markdown and plain text |

## Voice

- Address the reader as "you". Write "You can filter by date", not "Users can filter by date" or "One can filter by date". Use "the user" for a third person: when the reader is a developer or an administrator, "you" is the reader and "the user" is the person they serve.
- Avoid "we". "We recommend 3 retries" becomes "Use 3 retries". The exception is a real group that acted or decided, as in a design doc or an incident report.
- Use the present tense and the active voice.
- Use common contractions: *don't*, *isn't*, *can't*, *it's*, *you're*. They sound like a person. Do not contract a noun with a verb ("the job's failing").
- Be friendly and plain. Do not joke in instructions, and never joke about a procedure that can destroy data: a tired reader may take it literally.
- Leave out "please" in instructions and exclamation marks everywhere.
- Do not announce: "Later in this guide, we will cover…" Either cover it now or link to it.

## Headings

- Use sentence case: "Install the tools", not "Install The Tools".
- Say what the section holds. A task heading starts with a verb: "Backfill a partition". A concept heading names the concept: "Partition pruning".
- Do not skip levels, and do not use a heading for one short paragraph.
- Do not follow a heading with a sentence that repeats it.
- Keep code font out of headings where you can. Where you cannot, keep the identifier exact.

## Lists and tables

Choose by the shape of the content:

| Content | Form |
|---|---|
| Steps in order | Numbered list |
| Items in no order | Bulleted list |
| Terms with definitions, options with effects | Definition-style list: the term, then its description |
| Items with two or more attributes, or anything the reader looks up | Table |
| Reasoning, cause and effect | Paragraphs |

- Introduce a list with a sentence that ends in a colon.
- Make the items parallel: all sentences, or all fragments of the same form.
- Start each item with a capital letter. End it with a period only if it is a full sentence.
- Write each numbered step as a full sentence.
- In a table, keep column headings short, in sentence case, and put the unit in the heading: "Timeout (s)".
- Introduce a table in the sentence before it. Say what it shows.

## Steps

- One action per step. Combine two actions only when the reader does them as one.
- Start with the verb: "Run", "Open", "Set".
- Say where before what: "In the Airflow UI, open **Admin > Variables**."
- Put the condition first: "If the DAG is paused, unpause it."
- Do not write "if necessary" or "optionally". State the condition or the reason: "If the table already exists, skip this step." "To keep the old data, add `--no-truncate`."
- After a step that produces output, show the output or say what to look for.
- Put a warning before the step it applies to.
- Number the steps in one sequence for the whole procedure, so that "step 4" names exactly one step. Keep the sequence even when headings divide the procedure into stages.
- When a procedure grows past about ten steps, divide it into named stages.

## Code and technical notation

- Use code font for anything the reader types or the system prints: commands, flags, code, file names and paths, config keys and values, table and column names, environment variables, HTTP methods and status codes, and error text.
- Use a code block for anything the reader copies. Tag it with its language. Give one command per block when the reader runs them one at a time.
- Leave the shell prompt (`$`) out of commands, and show output in a separate block from the command.
- Follow the capitalization of the language or tool exactly: `SELECT` or `select` as the project writes it, `DataFrame`, `pandas`.
- Do not use a command or function name as a verb. Write "Run `ls` in both directories", not "`ls` both directories". Write "Use `cd` to change to the root directory", not "`cd` to the root directory".
- Do not inflect a word in code font. Write "values of type `integer`", not "`integer`s". Write "call `flush()` twice", not "`flush()`ing twice".
- Keep sentence punctuation outside the code font, unless it is part of the code.
- Say where a command runs when that is not obvious: on which host, in which directory, with which role.

### Placeholders

- Mark each placeholder the same way throughout a document. The default is angle brackets with a descriptive name in lowercase: `<bucket-name>`, `<run-date>`.
- Name the kind of thing. Avoid `foo`, `bar`, and `xxx`.
- Explain each placeholder right after the block: "Replace `<run-date>` with the partition date, in the form `YYYY-MM-DD`."
- Use the same placeholder name for the same thing everywhere.
- In prose, write about the thing in ordinary words: "The bucket name can have up to 63 characters", not "The `<bucket-name>` can have up to 63 characters".

### Examples

- Use realistic values that cannot be mistaken for real secrets or real people: `example.com`, `orders_2026`, `user_id = 1042`.
- Never paste a real credential, token, or personal record into a document, a ticket, or a message. Redact it in logs you quote.
- Make every example runnable as written, or mark clearly what the reader must change.

## Interface elements

- Put the exact label of a button, menu, tab, or field in bold: "Click **Trigger DAG**."
- Use these verbs:

| Action | Verb |
|---|---|
| A button, link, or tab, with a mouse | click (not "click on") |
| An item in a menu | choose: "Choose **File > Export**" |
| A checkbox, option, or row among several | select, deselect |
| Text in a field, by any means | enter |
| A key | press |
| A setting or feature | turn on, turn off |

- Say an item "appears", not "displays" or "shows up". Say an item you cannot use is "unavailable", not "disabled" or "grayed out".
- Do not give directions by position or color alone ("the red button on the right"). Name the label.

## Links and cross-references

- Make the link text name what the reader will find: "see [Backfill a partition](backfill.md)", not "click [here](backfill.md)" and not a bare URL in running prose.
- Use "above" and "below" only for something directly next to the sentence. For anything farther away, link to it.
- Link at the point of need. Do not collect links in a list that the reader must match to the text.
- Link to the source of a claim when the reader may want to check it.

## Numbers, units, dates, and versions

- Use numerals for anything measured or technical: `3 retries`, `5 minutes`, `2 TB`. In plain prose, spell out one through nine for casual counts ("two teams"), and never start a sentence with a numeral.
- Put a space between a number and its unit symbol: `200 ms`, `30 GB`. Do not hyphenate a number and a symbol ("a 30 GB table"). Do hyphenate a spelled-out unit used as a modifier ("a 30-day window").
- Do not mix a symbol with a spelled-out unit: `MB/s`, not "MB/second".
- Say which unit you mean when two are common: GB (10⁹ bytes) or GiB (2³⁰ bytes), seconds or milliseconds for a timeout.
- Spell out an uncommon unit at first use, with its symbol in parentheses.
- Write "more than 1,000 rows", not "over 1,000 rows". Use "fewer" for things you count and "less" for quantities.
- Use `%` with a numeral in technical text. Say "percentage" for an unspecified amount.
- For a range, use "to" in prose ("10 to 20 workers") and say whether the bounds are inclusive when it matters.
- Write dates as `YYYY-MM-DD`. Never write `03/04/26`, which different readers read as different days. In running prose where a numeric date would look out of place, spell out the month: "November 10, 2026".
- Write times on the 24-hour clock with the zone: `18:00 UTC` or `18:00Z`. For a local zone, give the offset: `18:00 GST (UTC+4)`. Give a cron schedule with its time zone.
- Convert a date or a time to these forms only when the source gives all of it. If the source says "the 28th" or "3 AM", keep its words and ask for the missing month or zone. Do not complete it from context.
- Do not imply more precision than you have: "about 4 minutes", not "241.3 seconds", unless the decimals mean something.
- Name versions exactly: "Airflow 2.9", not "Airflow version 2.9" or "the latest Airflow". For a range, write "2.9 or later" or "earlier than 2.9", not "newer", "higher", or "older".
- Avoid words that go stale: *new*, *currently*, *recently*, *soon*, *latest*, *now supports*. Give the version or the date instead: "Since 2.9, the scheduler…"

## Abbreviations

- Spell out an abbreviation at its first use in a document or a long section, with the short form in parentheses: "change data capture (CDC)". Skip this for terms every reader in the field knows: SQL, API, URL, CSV.
- Form the plural with an *s* and no apostrophe: "APIs", "DAGs".
- Do not use Latin abbreviations. Write "for example" or "such as" for *e.g.*, "that is" for *i.e.*, and "and so on" for *etc.* Better than "and so on": name the items, or say "including".
- Write "versus" in full, or rewrite to avoid it.
- Do not invent abbreviations to save space in prose.

## Notes and warnings

Use a labeled callout rarely. A page with five notes has none. Choose the label by the risk:

| Label | Use it for |
|---|---|
| **Note** | Useful information that the reader could miss without harm |
| **Important** | Something the task fails without |
| **Caution** | Risk of losing data, money, or time |
| **Warning** | Risk to people, or damage that cannot be undone |

Write the callout as an instruction, then the reason: "**Caution:** Back up the table before you run the migration. The migration drops the `legacy_id` column." Place it before the step.

## Figures

- Use a diagram when it shows a structure or a flow that prose would take a paragraph to describe. Refer to it in the text and say what it shows.
- Give every image alt text that states what the image tells the reader.
- Do not use a screenshot of text, such as a terminal or an error dialog. Paste the text, so that the reader can search it and copy it.
- Prefer a vector or text-based diagram that lives in the repository and can be updated in a diff.

## Writing for readers everywhere

Many readers of technical English read it as a second language, and many read it through a translation tool.

- Avoid idioms and sayings: "out of the box", "under the hood", "on the same page", "boil the ocean", "low-hanging fruit".
- Avoid cultural references and sports metaphors.
- Prefer one-word verbs to phrasal verbs where the one-word verb is common: "remove" for "get rid of", "investigate" for "look into". Keep the everyday ones that have no better form: "set up", "log in", "back up".
- Keep sentence structure simple and keep the small grammar words.
- Do not use color or direction as the only way to identify something.

## Usage list

### Prefer the direct form

| Avoid | Write | Why |
|---|---|---|
| X allows you to, X enables you to, X lets you | You can… with X | Makes the reader the subject. "Lets you" is fine when you describe features rather than give instructions. |
| once (for time) | after, when | "Once" also means "one time". |
| since (for cause) | because | "Since" also means "from that time". |
| while (for contrast) | although, whereas | "While" also means "during". |
| if (for alternatives) | whether | "Check whether the job finished", not "check if". "If" is for conditions. |
| which (restrictive) | that | "The table that holds orders" restricts. ", which holds orders," adds an aside and takes commas. |
| via | through, by, with, from | Plainer. |
| and/or | "A or B, or both", or pick one | Ambiguous. |
| disk(s), file(s) | disks, files | Use the plural. |
| desired, wish | want, or omit | "Select the folder", not "select the desired folder". |
| different than | different from | |
| comprised of | consists of, contains | |
| due to | because of, caused by | |
| as per | as, according to, or omit | |
| ensure (as filler) | make sure, or state the mechanism | "The check ensures quality" says nothing. "The check rejects rows with a null key" does. |

### One word or two

| Noun or adjective | Verb |
|---|---|
| setup | set up |
| login | log in |
| backup | back up |
| rollback | roll back |
| rollout | roll out |
| checkout | check out |
| lookup | look up |
| startup, shutdown | start up, shut down |

Also: "command line" as a noun and "command-line" as an adjective, "real time" as a noun and "real-time" as an adjective, "open source" in both roles, and one word for *filename*, *hostname*, *timestamp*, *runtime*, *metadata*, and *email*. Treat "data" as singular when it means a body of data: "The data is stored in S3."

### Terms to replace

Use the alternative in your own prose. When the old term is a literal identifier, command, or branch name, keep it exact and in code font: `kill -9`, `master`.

| Avoid in prose | Write |
|---|---|
| master/slave | primary/replica, primary/secondary, leader/follower |
| blacklist/whitelist | deny list/allow list |
| sanity check | consistency check, quick check |
| dummy (value, data) | placeholder, sample, test |
| kill (a process) | stop, end, cancel, terminate |
| hang (the system hangs) | stop responding |
| abort | stop, cancel |

### Words that describe software precisely

| Word | Meaning to keep |
|---|---|
| stop | cause a process to cease |
| cancel | stop something before it completes. Say what state that leaves behind: a canceled job can have written part of its output. |
| fail | end without achieving the result |
| run | what a process or job does. A person "runs" a command or a job. |
| start | begin a process. A person "opens" an app or a file. |
| default | the value in effect when nobody has set one |
| unavailable | cannot be used in the present state |
| deprecated | still supported, and discouraged. Name the replacement, and the removal version or date only if one is announced. |
