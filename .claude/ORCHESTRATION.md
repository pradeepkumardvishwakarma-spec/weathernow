# Orchestration setup (Claude Code)

This project is set up to be driven from **Claude Code** using a simple
orchestrator + sub-agents pattern, on top of the project rules in `CLAUDE.md`.

## How it's meant to work

- **CLAUDE.md** (repo root) — read automatically at the start of every Claude Code
  session in this repo. Contains the non-negotiable constraints from the brief
  (Riverpod only, clean architecture boundaries, no raw errors in UI, etc.) so they
  don't need to be repeated in every prompt.
- **Orchestrator** — the main Claude Code session itself. It plans each feature slice
  (e.g. "build the Favorites screen") and delegates focused sub-questions to the
  agents below rather than trying to hold every constraint in one giant prompt.
- **Sub-agents** (`.claude/agents/`):
  - `flutter-architect.md` — layer-boundary enforcement; called whenever a new file
    or feature is scaffolded, or when reviewing whether a diff crossed a layer it
    shouldn't have.
  - `riverpod-specialist.md` — provider design decisions (autoDispose vs persistent,
    avoiding unnecessary rebuilds).
  - `qa-reviewer.md` — the final gate before calling a screen "done"; checks the
    actual numbered behaviors in the client brief, not general best practice.

## Suggested real workflow

1. Open this repo in Claude Code / Cursor.
2. Prompt at the feature level ("build the Favorites screen per the brief"), not the
   file level — let the orchestrator decompose it.
3. When something touches architecture boundaries or state-management design,
   explicitly invoke the relevant sub-agent (e.g. "use flutter-architect to review
   this diff before I commit").
4. Before marking any of the four screens done, run the `qa-reviewer` agent against
   it and paste its checklist output into `docs/PROMPTS_LOG.md`.
5. Any time the AI's suggestion turns out to be wrong for this Flutter/Dart version
   or package API, log it immediately in `docs/AI_ASSISTANCE_NOTES.md` — don't
   reconstruct this from memory at the end.

## Note on this submission

This `.claude/` setup and `CLAUDE.md` were authored to define how the project *should*
be worked on in Claude Code. The accompanying `docs/PROMPTS_LOG.md` and
`docs/AI_ASSISTANCE_NOTES.md` should reflect the actual session run against this setup —
they are templates to fill in from a real Claude Code/Cursor run, not a substitute for one.
