# Requirements and assumptions

This file captures the functional and non-functional requirements and the assumptions for the workshop project.

## Functional requirements (IDs)

FR-01: User registration (US-04)
FR-02: User login (US-05)
FR-03: User logout (US-06)
FR-04: View feed (US-09)
FR-05: Create post (US-08)
FR-06: Posts include author and timestamp (US-09)
FR-07: Feed shows newest first (US-09)

## Non-functional requirements

NFR-01: Passwords stored with scrypt / slow salted hashing (US-07)
NFR-03: User-visible text displayed as plain text (US-11)
NFR-06: Docker usage (US-13)
NFR-10: Data persistence via volumes (US-13)
NFR-11: Automated tests for must stories (US-12)
NFR-12: CI runs on every push (US-14)

## Assumptions
- Times are stored in UTC.
- The initial datastore will be SQLite (development).
- The UI is minimal and primarily server-rendered.

## Out of scope
- Pagination (US-17)
- Post deletion (US-16)
