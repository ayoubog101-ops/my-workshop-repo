# Part C: Epics, User Stories and Board

## Board setup

Create a GitHub Project (Board layout) with these columns:

`Backlog` > `To Do` > `In Progress` > `Review / Testing` > `Done`

Add one card per story below. Use the labels `must`, `should`, `could` and `epic:*`. Link each pull request to its card with "Closes #number". Take screenshots of the board at the start, in the middle and at the end for the presentation.

The "Status" column below shows the state when the MVP was delivered. Move your own cards as you work and update this table to match your real board.

## Epics

| Epic | Goal |
|------|------|
| E1 Foundation | Repository, board, requirements, architecture, database design |
| E2 Identity | Register, log in, log out, secure passwords |
| E3 Social posts | Create posts and show the feed |
| E4 Quality and delivery | Tests, Docker, CI, README, demo |

## User stories

### E1 Foundation

**US-01 Set up repository and board** (Must, Status: Done)
As a developer, I want a Git repository and a project board, so that work is tracked from day one.
Acceptance criteria:
- Repository has README, `.gitignore`, and a folder structure for backend, tests, docs and workflows.
- Board has the five columns and all stories as cards.
Tasks: create repo, add `.gitignore`, create board, import stories.

**US-02 Document requirements and assumptions** (Must, Status: Done)
As a product owner, I want written requirements with IDs, so that everyone agrees on the scope.
Acceptance criteria:
- Functional and non-functional requirements have IDs and acceptance criteria.
- Assumptions and out-of-scope items are listed.
Tasks: write `01-requirements.md`, review against the brief.

**US-03 Design architecture and data model** (Must, Status: Done)
As a developer, I want an architecture diagram and an ADR, so that technical choices are explained.
Acceptance criteria:
- Diagram labels all components.
- At least one ADR lists context, decision, alternatives and trade-offs.
Tasks: draw diagram, write ADRs, design the `users` and `posts` tables.

### E2 Identity

**US-04 Register an account** (Must, Status: Done)
As a visitor, I want to register with a username and password, so that I can post.
Acceptance criteria:
- Valid input returns 201 and signs the user in.
- A taken username returns 409.
- A username that is not 3 to 20 letters, numbers or underscores returns 400.
- A password shorter than 8 characters returns 400.
Tasks: endpoint, validation, hashing, tests, registration form.

**US-05 Log in** (Must, Status: Done)
As a registered user, I want to log in, so that I can use my account.
Acceptance criteria:
- Correct credentials return 200 and set a session cookie.
- Wrong credentials return 401 with a message that does not reveal which part was wrong.
Tasks: endpoint, session handling, tests, login form.

**US-06 Log out** (Must, Status: Done)
As a signed-in user, I want to log out, so that nobody else can use my session.
Acceptance criteria:
- After logout, protected calls return 401.
- The page returns to the logged-out view.
Tasks: endpoint, button, test.

**US-07 Protect passwords** (Must, Status: Done)
As a user, I want my password stored safely, so that a data leak does not expose it.
Acceptance criteria:
- The database never contains the plain password.
- Hashing uses a salted, slow algorithm (scrypt).
Tasks: use Werkzeug hashing, add a test that reads the database directly.

### E3 Social posts

**US-08 Create a post** (Must, Status: Done)
As a signed-in user, I want to write a post, so that others can read it.
Acceptance criteria:
- Valid text (1 to 280 characters) returns 201 and is stored with author and UTC time.
- Empty or too long text returns 400.
- Without a session the call returns 401.
Tasks: endpoint, validation, composer form with character counter, tests.

**US-09 View the feed** (Must, Status: Done)
As a visitor, I want to see all posts, newest first, so that I can follow what people say.
Acceptance criteria:
- The feed shows author, text and creation date for every post.
- Posts from all users appear, newest first.
- The feed is visible without logging in.
Tasks: endpoint with join, feed rendering, tests.

**US-10 Clear feedback and states** (Should, Status: Done)
As a user, I want helpful messages, so that I know what went wrong.
Acceptance criteria:
- Errors are shown under the relevant form.
- An empty feed shows a friendly message.
- The layout works on a phone screen.
Tasks: error display, empty state, responsive CSS.

**US-11 Safe display of post text** (Must, Status: Done)
As a user, I want other people's posts to be shown as plain text, so that nobody can run scripts in my browser.
Acceptance criteria:
- Text such as `<script>` appears literally on screen.
Tasks: use `textContent`, add a test for stored content.

### E4 Quality and delivery

**US-12 Automated tests** (Must, Status: Done)
As a developer, I want automated tests, so that I can change code safely.
Acceptance criteria:
- Every Must story has at least one test.
- `pytest` passes locally and in CI.
Tasks: fixtures, auth tests, post tests, persistence test.

**US-13 Run with Docker** (Must, Status: Done)
As a lecturer, I want to start the app with one command, so that I can assess it quickly.
Acceptance criteria:
- `docker compose up --build` starts the app on port 8000.
- Data stays after `docker compose restart` and after `docker compose down` (but not after `down -v`).
Tasks: Dockerfile, compose file, volume, health check.

**US-14 Continuous integration** (Must, Status: Done)
As a developer, I want automatic checks on every push, so that broken code is found early.
Acceptance criteria:
- Workflow installs dependencies, runs tests and builds the image.
- A smoke test confirms the container answers.
Tasks: write workflow, check a green run.

**US-15 README and demo script** (Must, Status: Done)
As a lecturer, I want clear instructions, so that I can run and test the project without help.
Acceptance criteria:
- README lists prerequisites, environment variables, ports, test commands and troubleshooting.
Tasks: write README, rehearse the demo.

### Ideas for later (Could, Status: Backlog)

| ID | Story |
|----|-------|
| US-16 | Delete my own posts |
| US-17 | Pagination or "load more" in the feed |
| US-18 | Rate limiting on login |
| US-19 | Profile page showing one user's posts |

## Traceability

| Requirement | Stories |
|-------------|---------|
| FR-01 | US-04 |
| FR-02 | US-05 |
| FR-03 | US-06 |
| FR-04, FR-06, FR-07 | US-09 |
| FR-05, FR-08 | US-08 |
| FR-09, FR-10 | US-10 |
| NFR-01 | US-07 |
| NFR-03 | US-11 |
| NFR-06, NFR-10 | US-13 |
| NFR-11 | US-12 |
| NFR-12 | US-14 |
