# 10-Minute Presentation Guide

## Timing plan

| Time | Section | What to show |
|------|---------|--------------|
| 0:00 to 1:00 | Problem and assumptions | The customer statement. Three key assumptions: web app, username and password only, 280 character posts. |
| 1:00 to 2:30 | Requirements and method | `01-requirements.md` table of Must requirements. Why Kanban fits a small team with unclear requirements. |
| 2:30 to 3:30 | Board | The GitHub Project board with cards in every column and the weekly progress. |
| 3:30 to 5:00 | Architecture | The diagram. ADR-001: why a monolith and SQLite, and what it costs. |
| 5:00 to 8:00 | Live demo | See script below. |
| 8:00 to 9:00 | Docker and CI | The README command. A green GitHub Actions run. |
| 9:00 to 10:00 | Lessons | Two decisions or lessons. |

## Demo script (3 minutes)

1. Open http://localhost:8000. Point out that the feed is visible without an account.
2. Register as `demo_one`. The post form appears.
3. Post "Hello from demo_one". It shows at the top with author and date.
4. Click Log out. The form disappears.
5. Register as `demo_two` and post a second message. It appears above the first one.
6. Show the character counter and an error (try an empty post or wrong password on login).
7. Persistence: in a terminal run `docker compose restart`, refresh the page, and show both posts and log in again.
8. Optional: type `<b>test</b>` in a post to show that HTML is displayed as text.

## Backup plan

- Run the demo once before the presentation and keep the containers up.
- Keep screenshots of the feed and of the green CI run in case the network or Docker fails.

## Lessons learned (pick two)

- Choosing a monolith with SQLite saved days. The trade-off is that scaling would need PostgreSQL first.
- Writing acceptance criteria before code made the tests easy to write, because each criterion became a test.
- Limiting work in progress on the board made blocked work visible early.

## Likely questions

| Question | Short answer |
|----------|--------------|
| Why not microservices? | Two tables and one team. Microservices add network and deployment cost with no gain. See ADR-001. |
| How are passwords protected? | Salted scrypt hashes through Werkzeug. A test reads the database to prove no plain text is stored. |
| What happens if two people post at once? | SQLite serializes writes. At demo load this is invisible. |
| What would you do next? | Delete own posts, pagination, rate limiting, PostgreSQL and HTTPS. |
| Did you use AI? | Disclose according to your institution's policy, and be ready to explain every part of the code. |
