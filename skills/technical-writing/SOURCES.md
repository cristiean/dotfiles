# Sources

This file is for whoever maintains the skill. It records where each part comes from, what was left out, and how conflicts between the sources were settled. Check it before you change a rule.

The skill distills its sources. It paraphrases their guidance and uses its own examples. It does not reproduce their text. Read the originals: each is better than any summary of it.

Sources were read on 2026-11-10.

## What each source contributed

| Source | Used in | What was taken | What was left out |
|---|---|---|---|
| William Strunk Jr., *The Elements of Style* (1918), public domain. Text from [obra/the-elements-of-style](https://github.com/obra/the-elements-of-style). | `SKILL.md`, `references/sentences.md` | The principles of composition: one topic per paragraph with a topic sentence, active voice, positive form, specific and concrete language, omit needless words, parallel form, related words together, emphatic words last, one tense. The serial comma. | Most of the usage rules and the list of misused words, which are dated. |
| [STE80 Humanizer](https://github.com/Dodaios/ste80-humanizer) by Dodaios, MIT License, version 3.1.0. | `SKILL.md`, `references/sentences.md` | The "80 percent of Simplified Technical English" approach: one idea per sentence, condition first, keep the small words, verbs not nouns, simple tenses, honest modals, one term per thing, no noun stacks, warnings before steps. The fidelity check: list the facts, then compare. | Hard word limits, the ban on semicolons, the closed vocabulary, strict mode, and the checker script. |
| [blader/humanizer](https://github.com/blader/humanizer) by Siqi Chen, MIT License, and Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), by way of STE80 Humanizer. | "Patterns to remove" in `SKILL.md`, "Padding patterns" in `references/sentences.md` | The families of padding: false contrast, announcing, recap closers, reflex threes, inflation, "-ing" riders, stacked hedges, unnamed authority, decoration, chat residue, text about the text, retelling context. | The full catalog of 26 patterns and its numbering. |
| ASD-STE100 Simplified Technical English, by way of STE80 Humanizer. | `references/sentences.md` | Structure rules only, paraphrased. | The specification and its dictionary. This skill does not contain them and makes no claim of compliance. ASD-STE100 is a trademark of ASD. |
| [Diátaxis](https://diataxis.fr/) by Daniele Procida, CC BY-SA 4.0. | `references/document-types.md` | The four kinds of documentation, the two questions that tell them apart, the rules for each kind, and the advice to improve in small steps. | The theory chapters. |
| [Google developer documentation style guide](https://developers.google.com/style/highlights), CC BY 4.0. | `references/conventions.md` | Second person, active voice, conditions before instructions, sentence-case headings, list types, code font, bold for interface labels, descriptive link text, no pre-announcing, unambiguous dates, alt text, writing for a global audience. | The word list and the product-specific pages. |
| [Apple Style Guide](https://support.apple.com/guide/applestyleguide/welcome/web), © Apple Inc. | `references/conventions.md` | The usage entries that apply to any technical text: the reader as subject (*allow*, *enable*, *let*), *once*/*after*, *since*/*because*, *while*/*although*, *if*/*whether*, *that*/*which*, *via*, *and/or*, *desired*, *if necessary*, *optionally*, *please*, *new*, *latest*, *earlier*/*later* for versions, present tense, contractions, no first person, Latin abbreviations, interface verbs (*click*, *choose*, *select*, *enter*, *press*, *turn on*), technical notation (code font, placeholders, no command names as verbs, no inflected code), units of measure, international style for dates and numbers, lists, tables, and the inclusive-language replacements. | Product names, trademarks, hardware terms, and everything specific to Apple platforms. |
| Apple Human Interface Guidelines, [Writing](https://developer.apple.com/design/human-interface-guidelines/writing), © Apple Inc. | `references/interface-text.md` | Most important information first, fewest clear words, consistent terms, tone matched to the moment, verbs on actions, no "we", sparing possessives, error messages that say how to fix the problem and do not blame, hints in fields, empty states with a next step, settings described by what they do when on. | Device-specific guidance. |
| Eric S. Raymond and Rick Moen, [How To Ask Questions The Smart Way](http://www.catb.org/~esr/faqs/smart-questions.html). | `references/messages.md` | The "object, then deviation" subject line, goal before step, symptoms before theories, chronological order, precision over volume, the explicit ask, the follow-up note, and the advice on answering helpfully. | The contempt for the asker. The method is sound and the tone is not. |
| Eric S. Raymond, [How To Become A Hacker](http://www.catb.org/~esr/faqs/hacker-howto.html). | `references/messages.md` | "No problem should ever have to be solved twice", which here becomes: put the answer where the next person will look. Publishing useful information. Writing your own language well, and English as a working language for readers who learned it second. | Everything about becoming a hacker that is not about writing. This source says little about writing itself. |
| Virginia Shea, [*Netiquette*](http://www.albion.com/netiquette/book/TOC0963702513.html) (Albion Books, 1994). | `references/messages.md` | The core rules that bear on writing: remember the human, know where you are, respect other people's time, make yourself look good (check facts, make sense, spell correctly), share expert knowledge, respect privacy, forgive mistakes. From the chapters on electronic style and discussion groups: clear subject lines, no capitals for emphasis, plain text, limited recipients, no empty replies. | The material on 1990s networks, emoticons, signature files, and line lengths. |

## Added for data engineering

These parts come from no listed source. They were written for the owner's work:

- "What data engineering documents must state" in `references/document-types.md`.
- The skeletons for a README, runbook, reference entry, design doc, and incident report.
- Log lines, alerts, and command-line output in `references/interface-text.md`, which extend the Human Interface Guidelines from apps to pipelines and tools.
- Review comments, PR descriptions, commit messages, and status updates in `references/messages.md`.

## How conflicts were settled

| Conflict | Decision | Reason |
|---|---|---|
| Strunk says omit needless words. Simplified Technical English says do not drop words. | Cut words that carry no meaning. Keep articles, "that", and verbs. | Both aim at the reader. Telegraphic text is short and slow to parse. |
| Strunk puts the emphatic words last. Google and the smart-questions guide lead with the point. | Lead the document and the paragraph with the point. End the sentence on the new information. | They apply at different scales. |
| Simplified Technical English bans semicolons, contractions, and sentences over 25 words. Apple and Google use contractions, and Strunk uses semicolons. | Contractions are fine. Semicolons are rare. Length is a guide, and a condition stays with its consequence. | The strict rules exist for maintenance manuals. At "80 percent", structure matters and the hard limits do not. |
| STE80 bans em dashes. Apple allows them sparingly. | Avoid the em dash as general glue. | Language models overuse it, and a period or a colon nearly always says more. |
| Apple spells out one through nine. Engineering text is full of small technical numbers. | Numerals for anything measured or technical. Words only for casual counts. | A reader scanning for a value looks for digits. |
| Apple writes dates as "June 8, 2026" and also defines an international style. Google asks for unambiguous dates. | ISO 8601 by default, with UTC. | Data engineers compare dates across systems and time zones. |
| Apple avoids *kill*, *abort*, *master*, and similar terms. Tools use them as literal names. | Use the alternative in prose. Keep the literal name exact, in code font. | The reader has to type the literal name. |
| Apple and Google use American spelling and the serial comma. A project may use neither. | Match the project. American spelling and the serial comma when there is nothing to match. | Consistency within a document outranks any default. |
| The smart-questions guide tells the asker to expect rudeness. *Netiquette* says remember the human. | Take the method from the first and the manners from the second. | |

## Maintaining the skill

- Change a rule in one place. `SKILL.md` states each rule once, and the reference files give the detail.
- Change the house defaults in the table at the top of `references/conventions.md`.
- Keep `SKILL.md` short. It loads whenever the skill triggers. The reference files load only when needed.
- Test a change on the cases in `evals/` before you keep it, and judge the output on kept facts first, then on clarity.
- When a source publishes a new edition, read its change log and update the row above.
