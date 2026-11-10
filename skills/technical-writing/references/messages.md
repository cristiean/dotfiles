# Messages

Read this file when you write to a person: a question, a bug report, an answer, a review comment, a PR description, a commit message, an email, or a chat message.

A message differs from a document in one way that changes everything: a specific person must spend their time on it, and they did not ask to. The rules here all follow from respect for that time.

## Contents

- [Rules for every message](#rules-for-every-message)
- [Subject lines and titles](#subject-lines-and-titles)
- [Asking a question](#asking-a-question)
- [Reporting a bug](#reporting-a-bug)
- [Answering](#answering)
- [Closing the loop](#closing-the-loop)
- [Review comments](#review-comments)
- [PR descriptions](#pr-descriptions)
- [Commit messages](#commit-messages)
- [Status updates and handoffs](#status-updates-and-handoffs)
- [Email and chat](#email-and-chat)

## Rules for every message

- **Remember the person.** Write nothing you would not say to the reader's face. They cannot hear your tone, so irony and terseness read as hostility. State things plainly.
- **Respect their time.** Send one complete message. Give the reader what they need to act without a round of follow-up questions. Send it only to the people who need it.
- **Know where you are.** Each team and channel has its habits. Read a few recent messages and match the form.
- **Check before you send.** If you catch yourself writing "I believe" or "as far as I know", verify the fact or say plainly that you have not. Wrong information spreads faster than its correction.
- **Lead with what you need or what you decided.** Background follows, and only as much as the reader lacks.
- **Protect what is private.** Do not forward or quote a private message without asking. Do not paste credentials, tokens, or personal data into a ticket, a channel, or a document. Redact them from logs.
- **Forgive mistakes.** When someone gets something wrong, correct the fact, kindly and briefly. Correct a person in private when you can.

## Subject lines and titles

The subject line decides whether the right person opens the message. It applies to email subjects, issue titles, PR titles, and the first line of a thread.

Write it as **object, then deviation**: the thing that has the problem, then what is wrong with it. Aim for about 50 characters, and put the distinctive words first.

| Weak | Strong |
|---|---|
| Help needed!! | `orders_daily` DAG: load task times out since 2026-11-04 |
| Question about Spark | Spark 3.5 job writes 0 rows to Iceberg table, no error |
| Pipeline issue | `events_raw` has duplicate rows after backfill of 2026-10 |
| Update | Warehouse migration: cutover moved to 2026-11-18 |

Writing the subject this way also sharpens your own view of the problem: what exactly is affected, and since when?

When a thread changes topic, change its subject or start a new thread. When the problem is solved, say so in the thread, so the next reader does not spend time on it.

## Asking a question

First do your own work. Search the docs, the code, and earlier threads, and try the obvious things. This often answers the question. When it does not, it gives you the material for a good one.

Then write the question in this order:

1. **The goal.** Say what you are trying to achieve before the step you are stuck on. You may be stuck on the wrong path, and a reader who knows the goal can point to a better one.
2. **What happens.** Give the symptoms exactly and in the order they occurred: the command, the full error text, what you expected, and what you got. Paste text as text, not as a screenshot.
3. **The environment.** Versions, platform, configuration, data volume: whatever a reader needs to reproduce it.
4. **What changed.** Anything that changed shortly before the problem started.
5. **What you tried and what you found.** This saves the reader from suggesting it, and it shows where the problem is not.
6. **The ask.** Say exactly what you want from the reader: a pointer to documentation, a review of your approach, a decision. A bounded request gets answered. An open one gets postponed.

Further rules:

- **Describe symptoms, not your theory.** If you include a guess, label it as a guess and say why you have not confirmed it.
- **Be precise, not long.** Trim logs to the relevant lines. Reduce the failing case to the smallest one that still fails. Making it smaller often reveals the cause.
- **Do not call it urgent.** State the deadline and the impact, and let the reader judge: "This blocks the month-end report, due 2026-11-30."
- **Ask in the open channel** unless the matter is private. A public answer helps the next person.
- **Be courteous.** A plain "thanks" costs nothing. Flattery and apology are padding.

Example:

> **Subject:** `orders_daily`: Iceberg write fails with `CommitFailedException` when two runs overlap
>
> I'm backfilling `orders_daily` for 2026-10 by running several dates in parallel. Any two runs that overlap fail at the write step:
>
> ```
> org.apache.iceberg.exceptions.CommitFailedException: Cannot commit: stale table metadata
> ```
>
> A single run always succeeds. Spark 3.5.1, Iceberg 1.5.0, table partitioned by `order_date`.
>
> I raised `commit.retry.num-retries` from 4 to 10. The failures became less frequent but did not stop.
>
> Is a parallel backfill into one Iceberg table supported with this setup? If it is, which settings should I look at? If it is not, I'll run the dates in sequence.

## Reporting a bug

A bug report is a question with a fixed form. Its job is to let someone else see the failure for themselves.

```markdown
**Title:** <object, then deviation>

**What happened**
<The observed behavior, with exact error text.>

**What I expected**
<The behavior you expected, and why: a doc, a previous version.>

**Steps to reproduce**
1. <The smallest sequence that triggers it.>

**Environment**
<Versions, platform, configuration that matters.>

**Notes**
<How often it happens. When it started. What you tried. A workaround, if you have one.>
```

- State facts, then interpretations, and keep them apart.
- Do not claim a bug in someone else's software until you have ruled out your own setup. Say "I see this behavior" rather than "X is broken".
- Give the failing input, or the smallest input that fails.

## Answering

- **Answer the question that was asked**, in the first sentence. Then add what the asker needs to use the answer.
- **If you do not know, say so.** A confident wrong answer is worse than none. Say what you know, how you know it, and what you have not checked.
- **Read what they already tried.** Suggesting it again tells them you did not read the message.
- **Ask for the missing facts** when the question cannot be answered as it stands. Ask for all of them at once.
- **Point to the documentation, with a link** and the relevant line. This answers the question and shows where such answers live. A bare "read the docs" does neither.
- **Fix the approach, not the symptom.** If the asker is using the wrong tool, say so and name the right one, instead of patching the wrong path.
- **Show how you found the answer** when the method is reusable: the command you ran, the file you read.
- **Be gentle.** A person under pressure from a failing system can sound rude or careless without being either.
- **Then fix the source.** If the answer was missing from the docs, add it. No problem should have to be solved twice, and an answer given in chat is solved only for the people who were there.

## Closing the loop

When your problem is solved, post a short note in the same thread:

- Say what fixed it, in one or two sentences.
- Mark the thread or ticket as resolved.
- Thank the people who helped, by name.
- For a problem with depth, add the final statement of the problem and the dead ends worth avoiding. Put the dead ends after the solution. Do not tell it as a detective story.

Then ask whether a change to the documentation or the code would spare the next person the same problem.

## Review comments

- Comment on the code, not the author: "This loop reads the file once per row", not "You're reading the file once per row".
- Say what the problem is, why it matters, and what would fix it.
- Mark the weight of each comment, so the author knows what blocks the merge: a required change, a suggestion, or a question.
- Ask a real question when you do not understand. Do not disguise an instruction as a question.
- Say so when something is good, and say what is good about it.
- Take a long disagreement out of the review thread and into a call, then write the outcome back into the thread.

## PR descriptions

The reviewer needs to know what changes, why, and how to check it. Follow the repository's template if it has one. The same rules apply to a merge request (MR) in GitLab.

```markdown
<Title: what the change does, in the imperative, about 50 characters>

## What and why
<What this changes and the reason. Link the ticket.>

## How to review
<Where to start. What is mechanical and what needs thought.>

## How it was tested
<Commands run and results. What was not tested.>

## Risks and rollout
<What could break, how you would notice, and how to roll back.>
```

- Describe the change as it is now, not the history of how you got there.
- Say plainly what you did not do or did not test.
- Keep one purpose per PR. A description that needs "and also" twice describes two PRs.

## Commit messages

Follow the repository's existing style. Read `git log` first. Where there is none:

```text
Summarize the change in about 50 characters

Explain what changed and why, not how: the diff shows how.
Wrap the body at 72 characters. Mention side effects, and link
the ticket or the discussion.
```

- Write the subject in the imperative: "Add retry to S3 loader", not "Added" or "Adds".
- Leave a blank line between the subject and the body.
- Give the reason. A reader in two years has the diff and needs the "why".

## Status updates and handoffs

Lead with the state, then what the reader must do or know:

1. Where things stand, in one sentence: done, on track, at risk, or blocked.
2. What changed since the last update.
3. What happens next, and when.
4. What you need from the reader, if anything.

A handoff adds what a newcomer cannot guess: where the work lives, what is half-finished and in what state, what you would do next, and who knows the parts you do not.

## Email and chat

- Put the request or the decision in the first two lines. Many readers see only those.
- One topic per message. Two topics get one answer.
- In chat, write the whole message at once. Do not send "Hi" and wait.
- Quote only the lines you are answering.
- Address only the people who must act or must know.
- Do not write in capitals for emphasis. It reads as shouting.
- Use plain text that survives any client: short paragraphs, simple lists, code in code blocks.
- Do not send a message that adds nothing. Use a reaction for "+1" and "thanks".
- Do not send when angry or exhausted. Write it, wait, and read it again.
- Keep criticism specific and about the work, and offer a way forward.
