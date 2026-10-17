#!/usr/bin/env bash
# Creates labels and issues for the X Lite backlog and adds them to your GitHub Project.
# Run from Git Bash, one time only. Safe to re-run: existing titles are skipped.
#
# Before running:
#   gh auth login
#   gh auth refresh -s project

set -u

REPO="ayoubog101-ops/my-workshop-repo"
OWNER="ayoubog101-ops"
PROJECT=1

if ! gh auth status >/dev/null 2>&1; then
  echo "You are not logged in. Run: gh auth login"
  exit 1
fi

echo "Creating labels..."
gh label create must   --repo "$REPO" --color B60205 --description "Must have"   --force
gh label create should --repo "$REPO" --color FBCA04 --description "Should have" --force
gh label create could  --repo "$REPO" --color 0E8A16 --description "Could have"  --force
gh label create "epic:E1" --repo "$REPO" --color 1D76DB --description "Foundation"           --force
gh label create "epic:E2" --repo "$REPO" --color 5319E7 --description "Identity"             --force
gh label create "epic:E3" --repo "$REPO" --color 0052CC --description "Social posts"         --force
gh label create "epic:E4" --repo "$REPO" --color C5DEF5 --description "Quality and delivery" --force

EXISTING="$(gh issue list --repo "$REPO" --state all --limit 200 --json title --jq '.[].title')"

add_issue() {
  local title="$1" labels="$2" body="$3" url
  if printf '%s\n' "$EXISTING" | grep -Fxq "$title"; then
    echo "Skipping (already exists): $title"
    return
  fi
  url="$(gh issue create --repo "$REPO" --title "$title" --body "$body" --label "$labels")" || {
    echo "FAILED to create: $title"
    return
  }
  echo "Created: $url"
  gh project item-add "$PROJECT" --owner "$OWNER" --url "$url" >/dev/null ||
    echo "Could not add to project: $url"
}

echo "Creating issues..."

add_issue "US-01 Set up repository and board" "must,epic:E1" "As a developer, I want a Git repository and a project board, so that work is tracked from day one.

Acceptance criteria:
- Repository has README, .gitignore, and folders for backend, tests, docs and workflows.
- Board has the five columns and all stories as cards.

Tasks: create repo, add .gitignore, create board, import stories."

add_issue "US-02 Document requirements and assumptions" "must,epic:E1" "As a product owner, I want written requirements with IDs, so that everyone agrees on the scope.

Acceptance criteria:
- Functional and non-functional requirements have IDs and acceptance criteria.
- Assumptions and out-of-scope items are listed.

Tasks: write docs/01-requirements.md, review against the brief."

add_issue "US-03 Design architecture and data model" "must,epic:E1" "As a developer, I want an architecture diagram and an ADR, so that technical choices are explained.

Acceptance criteria:
- Diagram labels all components.
- At least one ADR lists context, decision, alternatives and trade-offs.

Tasks: draw diagram, write ADRs, design the users and posts tables."

add_issue "US-04 Register an account" "must,epic:E2" "As a visitor, I want to register with a username and password, so that I can post.

Acceptance criteria:
- Valid input returns 201 and signs the user in.
- A taken username returns 409.
- A username that is not 3 to 20 letters, numbers or underscores returns 400.
- A password shorter than 8 characters returns 400.

Tasks: endpoint, validation, hashing, tests, registration form."

add_issue "US-05 Log in" "must,epic:E2" "As a registered user, I want to log in, so that I can use my account.

Acceptance criteria:
- Correct credentials return 200 and set a session cookie.
- Wrong credentials return 401 with a message that does not reveal which part was wrong.

Tasks: endpoint, session handling, tests, login form."

add_issue "US-06 Log out" "must,epic:E2" "As a signed-in user, I want to log out, so that nobody else can use my session.

Acceptance criteria:
- After logout, protected calls return 401.
- The page returns to the logged-out view.

Tasks: endpoint, button, test."

add_issue "US-07 Protect passwords" "must,epic:E2" "As a user, I want my password stored safely, so that a data leak does not expose it.

Acceptance criteria:
- The database never contains the plain password.
- Hashing uses a salted, slow algorithm (scrypt).

Tasks: use Werkzeug hashing, add a test that reads the database directly."

add_issue "US-08 Create a post" "must,epic:E3" "As a signed-in user, I want to write a post, so that others can read it.

Acceptance criteria:
- Valid text (1 to 280 characters) returns 201 and is stored with author and UTC time.
- Empty or too long text returns 400.
- Without a session the call returns 401.

Tasks: endpoint, validation, composer form with character counter, tests."

add_issue "US-09 View the feed" "must,epic:E3" "As a visitor, I want to see all posts, newest first, so that I can follow what people say.

Acceptance criteria:
- The feed shows author, text and creation date for every post.
- Posts from all users appear, newest first.
- The feed is visible without logging in.

Tasks: endpoint with join, feed rendering, tests."

add_issue "US-10 Clear feedback and states" "should,epic:E3" "As a user, I want helpful messages, so that I know what went wrong.

Acceptance criteria:
- Errors are shown under the relevant form.
- An empty feed shows a friendly message.
- The layout works on a phone screen.

Tasks: error display, empty state, responsive CSS."

add_issue "US-11 Safe display of post text" "must,epic:E3" "As a user, I want other people's posts shown as plain text, so that nobody can run scripts in my browser.

Acceptance criteria:
- Text such as a script tag appears literally on screen.

Tasks: use textContent, add a test for stored content."

add_issue "US-12 Automated tests" "must,epic:E4" "As a developer, I want automated tests, so that I can change code safely.

Acceptance criteria:
- Every Must story has at least one test.
- pytest passes locally and in CI.

Tasks: fixtures, auth tests, post tests, persistence test."

add_issue "US-13 Run with Docker" "must,epic:E4" "As a lecturer, I want to start the app with one command, so that I can assess it quickly.

Acceptance criteria:
- docker compose up --build starts the app on port 8000.
- Data stays after docker compose restart and after docker compose down (but not after down -v).

Tasks: Dockerfile, compose file, volume, health check."

add_issue "US-14 Continuous integration" "must,epic:E4" "As a developer, I want automatic checks on every push, so that broken code is found early.

Acceptance criteria:
- Workflow installs dependencies, runs tests and builds the image.
- A smoke test confirms the container answers.

Tasks: write workflow, check a green run."

add_issue "US-15 README and demo script" "must,epic:E4" "As a lecturer, I want clear instructions, so that I can run and test the project without help.

Acceptance criteria:
- README lists prerequisites, environment variables, ports, test commands and troubleshooting.

Tasks: write README, rehearse the demo."

add_issue "US-16 Delete my own posts" "could,epic:E3" "Idea: let users delete their own posts. Stays in Backlog."
add_issue "US-17 Pagination or load more in the feed" "could,epic:E3" "Idea: paginate the feed to limit the first page size. Stays in Backlog."
add_issue "US-18 Rate limiting on login" "could,epic:E2" "Idea: rate limit login attempts to slow down password guessing. Stays in Backlog."
add_issue "US-19 Profile page showing one user's posts" "could,epic:E3" "Idea: a page that lists the posts of a single user. Stays in Backlog."

echo
echo "Done. Open the board: https://github.com/users/$OWNER/projects/$PROJECT"
