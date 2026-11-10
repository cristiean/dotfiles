# Interface text

Read this file when you write text that a program shows to a person: error messages, command-line output and help, log lines, alerts, labels, and descriptions of options.

Interface text is read in the middle of a task, often when something has just gone wrong. The reader gives it a glance. It has to work in that glance.

## Contents

- [Rules for all interface text](#rules-for-all-interface-text)
- [Error messages](#error-messages)
- [Command-line output and help](#command-line-output-and-help)
- [Log lines](#log-lines)
- [Alerts and notifications](#alerts-and-notifications)
- [Labels, options, and empty states](#labels-options-and-empty-states)

## Rules for all interface text

- **Put the most important information first.** The first words may be the only ones read.
- **Use the fewest words that are still clear.** Check that each word needs to be there. Then check that the message is still a sentence a person would say.
- **Use one term for each thing**, everywhere in the product and its documentation. Keep a short word list for the project and follow it.
- **Match the tone to the moment.** An error during a payment or a production deploy calls for calm, direct words. Save warmth and humor for moments when nothing is at stake, and leave them out when unsure.
- **Write for everyone.** Use plain words, no idioms, and no jargon the user has not met in the interface.
- **Do not say "we".** In a program's voice it is unclear who "we" is. Write "Unable to load the schema", not "We're having trouble loading the schema".
- **Use possessives sparingly.** "Tables", not "Your tables", unless the contrast with someone else's matters.
- **Choose a capitalization style for each kind of element** and keep it: for example, sentence case for messages and descriptions.

## Error messages

A good error message answers three questions: what happened, why, and what the reader can do now.

| Weak | Better |
|---|---|
| Invalid input. | `start_date` must be a date in the form `YYYY-MM-DD`. Got `11/04/2026`. |
| Error: access denied | Cannot write to `s3://analytics-prod/orders/`: role `etl-writer` lacks `s3:PutObject`. Ask the platform team to grant it, then rerun with `--resume`. |
| Something went wrong. | The load stopped after 3 failed attempts to reach `api.example.com` (timeout 30 s). No rows were written. Rerun the job when the API is reachable. |
| Oops! That didn't work. | The file `2026-11-04.csv` has 14 columns. The table `orders` expects 12. |

- **Say what happened in terms the reader knows.** Name the object: the file, the table, the parameter.
- **Include the values.** Show what the program received and what it expected. A message without values forces the reader to reproduce the failure just to learn what it was.
- **Say what state things are in.** After a failed write, the reader's first question is whether anything was written.
- **Say what to do next**, as an instruction. "Choose a name with at least 8 characters" helps. "That name is too short" only reports.
- **Tell the reader how to do it right** instead of listing what is wrong: "Use only letters and digits", not "Don't use symbols".
- **Do not blame.** "The file has no header row", not "You forgot the header row".
- **Do not apologize, joke, or exclaim.** "Oops" and "Uh-oh" sound insincere when a job has just failed.
- **Do not expose internals as the whole message.** A stack trace or an error code helps the developer. Put a plain sentence first and keep the code after it, where support can find it.
- **Keep the wording stable.** People search for error text. Change it only to fix it.
- **Prevent the error where you can.** If one message appears often, the fix belongs in the design, not in the wording.

## Command-line output and help

- **Say what the command did, in the past tense, with counts:** "Loaded 1,204,331 rows into `orders` in 42 s."
- **Stay quiet on success** unless the reader needs a result. Offer `--verbose` for the rest.
- **Print results to standard output and diagnostics to standard error**, so that output can be piped.
- **Before a destructive action, say exactly what will be affected and ask:** "This deletes 3 partitions of `orders` (2026-10-01 to 2026-10-03). Continue? [y/N]"
- **For a long operation, show progress** in a form that also works in a log file.
- **In help text, lead with a one-line description**, then usage, then options. Describe each option by what it does when set, and give its default and unit: "`--timeout <seconds>`  Stop waiting for the upstream table after this many seconds. Default: 7200."
- **Include one or two examples** for the most common tasks.
- **Name flags as the user thinks of them** and keep names consistent across commands: if one command has `--dry-run`, no other calls it `--simulate`.

## Log lines

A log line is read later, out of context, by someone searching for a cause.

- **Record one event per line**, in the past tense: "Wrote 12,000 rows to `orders_clean`."
- **Include the identifiers that connect it to other lines:** run ID, job name, partition, file.
- **Include values with units:** "Waited 30 s for lock on `orders`", not "Waited for lock".
- **Put the fixed text first and the variable parts after it**, so that lines of one kind can be searched and grouped.
- **Use each level for one purpose.** An error is something that needs a person. A warning is something unexpected that the program handled. Info is a normal milestone. If errors appear in every healthy run, nobody will read them in a failed one.
- **Say what the program will do next** when it matters: "Retrying in 4 s (attempt 2 of 3)."
- **Never log secrets or personal data.**

## Alerts and notifications

An alert interrupts someone. It must justify the interruption in its first line.

- **Title:** what is wrong, where, and how bad, in that order: "`orders_daily` load is 3 hours late (SLA: 06:00 UTC)".
- **Body:** the impact, the evidence (the value and the threshold), and the first thing to do. Link the runbook and the dashboard.
- **Send it only to someone who can act**, and only when action is needed. Choose the channel by urgency.
- **Say when it clears.**

## Labels, options, and empty states

- **Label an action with a verb** that says what happens: "Run backfill", "Export CSV". Avoid "OK", "Submit", and "Click here".
- **Label a setting with a short noun phrase.** If the label is not enough, add one line that says what the setting does when it is on. The reader can infer the opposite.
- **Lead a flow with consistent steps.** If the first screen says "Continue", the second does not say "Next".
- **In an input field, show the expected format** as a hint or an example: `YYYY-MM-DD`, `name@example.com`.
- **Show a validation message next to the field** it concerns.
- **Use an empty state to say what belongs there and how to add it:** "No runs yet. Trigger the DAG to create the first run."
- **Link to the place** instead of describing where it is.
