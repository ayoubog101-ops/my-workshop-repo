# Part A: Requirements Document

Project: X Lite, a small social media MVP
Version: 1.0

## 1. Customer statement

"We need a web or mobile application where users can create an account, log in, view all posts published on the platform, and create their own posts. It should be easy to use and easy to run locally using Docker."

## 2. Assumptions

| ID | Assumption |
|----|-----------|
| AS-01 | The product is a web application. It is easier to demo and to run in Docker than a mobile app. |
| AS-02 | The MVP is for a demo to investors, not for production traffic. Expected load is a few users at a time. |
| AS-03 | Users sign up with a username and a password. Email is not collected, so there is no email verification or password reset. |
| AS-04 | Posts are short plain text, up to 280 characters, like the product being imitated. |
| AS-05 | Anyone can read the feed without an account. Only signed-in users can post. |
| AS-06 | Posts cannot be edited or deleted in the MVP. |
| AS-07 | All times are stored in UTC and shown in the viewer's local time. |
| AS-08 | The feed shows the 200 newest posts. Pagination is out of scope. |

## 3. Functional requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | A visitor can register with a unique username and a password. | Must |
| FR-02 | A registered user can log in with username and password. | Must |
| FR-03 | A logged-in user can log out. | Must |
| FR-04 | A visitor can view the feed of all posts from all users. | Must |
| FR-05 | A logged-in user can create a text post. | Must |
| FR-06 | Each post in the feed shows its author, text and creation date. | Must |
| FR-07 | The feed lists posts newest first. | Must |
| FR-08 | Creating a post requires authentication. | Must |
| FR-09 | The interface shows the logged-in user's name and hides the post form from visitors. | Should |
| FR-10 | The interface shows clear error messages (wrong password, taken username, empty post). | Should |

## 4. Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-01 | Security | Passwords are stored only as salted hashes (scrypt through Werkzeug). Plain text is never stored or logged. |
| NFR-02 | Security | Login errors do not reveal whether a username exists. |
| NFR-03 | Security | Post text is rendered as plain text in the browser, so injected HTML or scripts do not run. |
| NFR-04 | Security | All database queries use bound parameters. Session cookies are HttpOnly and SameSite=Lax. |
| NFR-05 | Security | Secrets come from environment variables and are never committed. |
| NFR-06 | Persistence | Users and posts are kept in a SQLite database on a Docker volume and survive container restarts. |
| NFR-07 | Performance | Loading the feed and creating a post each take under 500 ms at demo load. |
| NFR-08 | Usability | A new user can register and publish a first post in under one minute, with no instructions. |
| NFR-09 | Usability | The page works on a phone screen and a desktop screen. |
| NFR-10 | Reproducibility | The whole system starts with `docker compose up --build`. |
| NFR-11 | Maintainability | Automated tests cover every functional requirement marked Must. |
| NFR-12 | Quality | A CI pipeline installs dependencies, runs tests and builds the Docker image on every push. |

## 5. Acceptance criteria

Each criterion is written to be testable. The last column names the automated test or the manual step that proves it.

| Req | Acceptance criterion | Evidence |
|-----|---------------------|----------|
| FR-01 | Given a new username and a password of 8 or more characters, registration returns 201 and the user is signed in. A taken username (any letter case) returns 409. A bad username or short password returns 400. | `test_register_creates_account_and_logs_in`, `test_duplicate_username_rejected_case_insensitive`, `test_register_validates_input` |
| FR-02 | Correct credentials return 200 and open a session. Wrong credentials return 401. | `test_login_success_and_logout`, `test_login_wrong_password` |
| FR-03 | After logout, `/api/me` returns 401. | `test_login_success_and_logout` |
| FR-04 | `/api/posts` works without a session and returns posts from every user. | `test_feed_is_public`, `test_feed_shows_all_users_newest_first` |
| FR-05 | A signed-in user posting valid text gets 201 and the post is stored. Empty text and text over 280 characters return 400. | `test_create_post_appears_in_feed_with_author_and_date`, `test_empty_and_too_long_posts_rejected` |
| FR-06 | Each feed item has `author`, `content` and `created_at`. | `test_create_post_appears_in_feed_with_author_and_date` |
| FR-07 | The feed is sorted by creation time, newest first. | `test_feed_shows_all_users_newest_first` |
| FR-08 | A post request without a session returns 401. | `test_create_post_requires_authentication` |
| FR-09 | Manual: the post form only appears after login. | Demo checklist in the README |
| FR-10 | Manual: errors appear in red under the form. | Demo checklist in the README |
| NFR-01 | The stored value differs from the password and starts with a hash scheme prefix. | `test_password_is_hashed_in_database` |
| NFR-02 | Wrong password and unknown user return the same message. | `test_login_unknown_user_gives_same_error` |
| NFR-03 | The API stores text as typed and the frontend uses `textContent`, never `innerHTML`, for user text. | `test_html_is_stored_as_plain_text`, code review of `app.js` |
| NFR-06 | After the app is recreated on the same database, users and posts are still there. | `test_data_persists_across_app_restart`, manual `docker compose restart` |
| NFR-10 | A clean clone starts with one command and answers on port 8000. | CI smoke test, manual run |
| NFR-12 | A push triggers the workflow and it reports test and build results. | GitHub Actions run |

## 6. Out of scope

These items were left out on purpose so the MVP stays small and finishes on time.

- Editing or deleting posts
- Likes, replies, follows, hashtags and direct messages
- Image upload
- Email verification and password reset
- Pagination and live updates
- Rate limiting and CAPTCHA
- Production deployment and HTTPS setup (a real deployment would need a reverse proxy with TLS and a strong `SECRET_KEY`)
