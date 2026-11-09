# Architecture Decision Records

Decisions listed in the order they were **made**, not the order they were written down. Backfilled records
are numbered by decision date, because a record's number is how it is cited and a number that reflects write
order would misrepresent history.

Format: [MADR](https://adr.github.io/madr/). One file per decision, `NNNN-slug.md`, with front matter carrying
`status` and `date`. This index must list every record - an unlisted record is a decision nobody will find.

| # | Date | Decision |
|:--|:--|:--|
| [0001](0001-canonical-state-in-gaugeblock.md) | 2026-10-29 | Canonical suite state lives in `.gaugeblock`, rooted at the git common dir |
| [0002](0002-telemetry-spans-are-contract-types.md) | 2026-11-05 | Flight-recorder spans are shared contract types in an append-only log |
| [0003](0003-receipts-cannot-exceed-evidence.md) | 2026-11-06 | A verification receipt may never be stronger than the evidence behind it |
| [0004](0004-one-json-envelope.md) | 2026-11-06 | Every binary emits one `--json` envelope |
| [0005](0005-reference-docs-live-in-docs.md) | 2026-11-06 | Reference documents live in `docs/`; README, CHANGELOG and AGENTS stay at the root |
| [0006](0006-composition-roots-are-a-layer.md) | 2026-11-06 | A crate whose product *is* composition gets its own layer, and the exemption is directional |
| [0007](0007-tickets-belong-to-a-repository.md) | 2026-11-07 | A ticket belongs to one repository; its receipt names the repo, branch, commits and chain |
| [0008](0008-a-suite-declares-its-members.md) | 2026-11-07 | A suite declares its members; membership is never inferred from layout |
| [0009](0009-source-follows-the-branch.md) | 2026-11-08 | Source state follows the branch; derived and coordination state follows the checkout (amends 0001) |

Decisions sharing a date are ordered by when the decision was actually reached, which for a same-day batch is
the order the work was done rather than the order of filenames chosen afterwards.
