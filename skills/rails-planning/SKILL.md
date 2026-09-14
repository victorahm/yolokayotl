---
name: rails-planning
description: Plan a large feature or epic for a Ruby on Rails project by splitting it into small, vertical, independently-shippable slices, and create a real tracked ticket for each slice using the current ticket system (Redmine / GitHub / GitLab). Activate when the user asks to plan a big feature, break down an epic, estimate/split into tasks, outline small features for an epic, or "split this feature". Also activates on "plan", "epic", "break down", "slices", "tickets".
---

# Rails: Planning & Slicing

Takes a large feature/epic and turns it into small **vertical** slices that each
deliver end-user value independently, then creates a real issue/ticket for every
slice in the project's ticket tracker (Redmine, GitHub, or GitLab) with proper
dependency links and acceptance criteria.

## Principles

- **Vertical slices**: each slice delivers a small slice of end-user value
  (touches the stack from model → controller → view, not a single layer). Avoid
  horizontal layers like "build all models first".
- **Independence**: each slice is independently shippable and testable. Order
  them by dependency; small ones first, risky ones early.
- **Real tickets**: the sliced plan becomes actual tickets in the ticket
  tracker, not just a markdown doc. Each ticket links its parent epic and its
  dependencies.
- **Acceptance criteria**: each slice has concrete, checkable acceptance
  criteria ("When X then Y") that a tester/agent can verify.

## How to Slice

1. **Understand the epic**: read linked ticket details from the repo's tracker.
2. **Define the happy-path end state**: the "done" definition of the whole
   feature.
3. **Break into vertical slices**, each:
   - model + migration + controller + view (when applicable),
   - a happy path + one or two edge cases,
   - its own acceptance criteria,
   - a rough dependency on earlier slices.
4. **Order** slices by dependency/risk; small-first.
5. **Decide the tracker**: use the project's ticket system —
   - Redmine: `redmine issues create`, `redmine issues relations`,
   - GitHub: `gh issue create` + labels,
   - GitLab: `glab issue create` + labels.
   Confirm the tracker + project scope with the user if unclear.

## Outputs

For each slice, create a ticket in the tracker with:

- A clear title (imperative: "Add X so that Y").
- Description with **acceptance criteria** ("Given/When/Then" or bullets).
- **Dependencies** on earlier slices (linked so the agent/tracker knows order).
- **Parent epic** link (Redmine: `redmine issues relations create <id>
  --relation-type parent --issue-id <parent>`; GitHub: mention `parent: #N` in
  body; GitLab: label or parent MR link).
- Assignee if known; priority; estimated points if the tracker supports it
  ("points" — Redmine via custom field only if the project uses it; otherwise
  always ask/confirm rather than guess a custom-field parsing).

Return the **list of created tickets with their URLs** (`redmine issues view
<id> -o json`, `gh issue view <num> --json url`, `glab issue view <iid> --json
web_url`) so the user can open each one.

## Ticket Creation Conventions

- Prefer creating slices as **Redmine issues** when the project has a Redmine
  instance; fall back to GitHub/GitLab issues when that's what the repo uses.
- Keep each ticket small — if a slice is > ~3 points of work, split further.
- Put the **acceptance criteria in the ticket description**, not just in the
  plan markdown.
- Link dependencies BEFORE delivering to the user so the ticket set is
  navigable.

## Simple Vertical-Slice Template (for the ticket body)

```markdown
## Purpose
_One sentence: what end-user value this slice delivers._

## Acceptance Criteria
- [ ] Given <context>, when <action>, then <observable result>
- [ ] Given <context>, when <edge case>, then <safe behavior>

## Dependencies
- Parent epic: <link or #N>
- Depends on: <slice #N / #N>
```

## After Creating Tickets

- Summarize concisely: epic → N vertical slices, ordered, each with its ticket
  URL.
- Offer the "next slice to build" (the first dependent-unblocked slice) as a
  concrete next action.
- Provide clickable ticket URLs (not bare IDs) for each created ticket.
