# Architecture & ADRs

This file contains a short list of ADRs and architecture notes.

## ADR-001: Web framework
Decision: Use Flask for a small workshop app.
Context: Small footprint, easy to test and dockerize.
Alternatives: FastAPI, Django.
Consequences: Simple routing and testability.

## ADR-002: Data store
Decision: SQLite for MVP, swap to PostgreSQL in production.
