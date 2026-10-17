# Part B: Methodology Selection

## Decision

I chose **Kanban with short weekly reviews** (sometimes called Scrumban).

## Context that drives the choice

- **Team size:** one or two people. Scrum roles (Product Owner, Scrum Master, team) and ceremonies add overhead that a pair cannot absorb.
- **Uncertain requirements:** the customer gave a short statement with little detail. We expect to learn and adjust as we build. That rules out Waterfall.
- **Short delivery window:** a few weeks, ending in a demo. We need a steady flow of small finished pieces more than fixed sprint commitments.

## Options compared

| Criterion | Waterfall | Scrum | Kanban (chosen) |
|-----------|-----------|-------|-----------------|
| Handles unclear requirements | Poor. Requirements are frozen early. | Good | Good |
| Overhead for 1 to 2 people | Low | High (planning, daily, review, retro) | Low |
| Visibility of progress | Low until the end | Good | Very good, through the board |
| Fits a hard demo date | Risky. Testing comes last. | Good | Good, if the work in progress is limited |
| Allows reprioritizing mid-way | Hard | Only between sprints | Any time |

## How the work is planned, prioritized and reviewed

**Planning.** At the start, the requirements are turned into epics and user stories (see `03-backlog.md`). Every story goes on the board in the Backlog column. The four suggested iterations in the brief are used as milestones, not as fixed sprints.

**Prioritization.** I use MoSCoW (Must, Should, Could, Won't).
- Must stories are the minimum acceptance checklist from the brief.
- Should stories improve usability.
- Could stories are only started when all Must stories are done.

The next card pulled into To Do is always the highest priority one that is not blocked.

**Workflow and limits.** Columns: Backlog, To Do, In Progress, Review / Testing, Done.
- Work in progress limit: 2 cards in In Progress and 2 in Review / Testing for a pair, 1 and 1 for a solo student.
- A card moves to Done only when its acceptance criteria pass and its tests are green in CI.

**Review.**
- A 15 minute review at the end of each week: what moved to Done, what is blocked, whether priorities should change.
- Each pull request is checked against the acceptance criteria on the linked card.
- A demo rehearsal in the last week, following the presentation guide.

**Metrics.** Cards finished per week and the age of the oldest card in progress. If a card stays in progress for more than three days, it is too big and gets split.

## Risks and how the method handles them

| Risk | Response |
|------|----------|
| Requirements change after feedback | Add or reorder cards. No sprint is broken. |
| Work piles up in testing | WIP limits make this visible early. |
| Demo day arrives with unfinished features | Must stories are done first. Could stories are cut without harm. |
