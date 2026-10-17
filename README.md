# X Lite

A small social media MVP. Users can register, log in, log out, read a public feed and publish short posts. Built with Flask, SQLite and plain JavaScript, and packaged with Docker.

## Run it with Docker

Prerequisites: Docker with Compose v2 (Docker Desktop or Docker Engine).

```bash
git clone <your-repository-url>
cd <your-repository-folder>
docker compose up --build
```

Then open **http://localhost:8000**.

No other step is needed. A `.env` file is optional (see below).

To stop the app, press `Ctrl+C` or run `docker compose down`.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `SECRET_KEY` | A demo value in `compose.yaml` | Signs session cookies. Use a long random value outside a local demo. |
| `DATABASE_PATH` | `/data/app.db` | SQLite file location inside the container. Set by `compose.yaml`. |

To set your own key:

```bash
cp .env.example .env
# edit .env and put a long random string after SECRET_KEY=
docker compose up --build
```

Never commit `.env`. The file `.env.example` only contains a safe placeholder.

## Data and persistence

Data lives in the Docker volume `xlite-data`, mounted at `/data`.

| Action | Data kept? |
|--------|-----------|
| `docker compose restart` | Yes |
| `docker compose down` then `docker compose up` | Yes |
| `docker compose down -v` | No, the volume is deleted |

The database tables are created automatically on first start. There is no seed or migration step.

## Try it (demo checklist)

1. Open http://localhost:8000. The feed is visible without an account.
2. Click Register, create a user (username 3 to 20 letters, numbers or underscores, password of 8 or more characters).
3. Write a post. It appears at the top with author and date.
4. Log out, then register or log in as another user and post again. Newest posts stay on top.
5. Run `docker compose restart`, refresh the page and check that users and posts are still there.

## Run the tests

Prerequisites: Python 3.12 or newer.

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r backend/requirements-dev.txt
pytest -v
```

The tests use a temporary database and do not touch your Docker data.

## Run without Docker (optional)

```bash
pip install -r backend/requirements.txt
cd backend
DATABASE_PATH=./local.db SECRET_KEY=dev flask --app wsgi run --port 8000
```

On Windows PowerShell, set the variables with `$env:DATABASE_PATH="./local.db"` first.

## Project structure

```
backend/           Flask app, static frontend and requirements
  app/__init__.py  API routes, database setup
  app/static/      index.html, app.js, style.css
tests/             pytest tests
docs/              Requirements, methodology, backlog, architecture and ADRs, presentation guide
.github/workflows/ CI pipeline
Dockerfile         Image for the app
compose.yaml       App and persistent volume
```

## Documentation

- [Requirements](docs/01-requirements.md)
- [Methodology](docs/02-methodology.md)
- [User stories and board](docs/03-backlog.md)
- [Architecture and ADRs](docs/04-architecture.md)
- [Presentation guide](docs/05-presentation-guide.md)

## CI

The workflow in `.github/workflows/ci.yml` runs on every push and pull request. It installs dependencies, runs `pytest`, builds the Docker image, starts it and checks `/api/health`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Port 8000 is already in use | Change the left side of `"8000:8000"` in `compose.yaml` (for example `"8080:8000"`) and open that port. |
| `docker compose` not found | Install Docker Desktop, or use `docker-compose` on older installs. |
| Page does not load right after start | Wait a few seconds for the build and the first start, then refresh. Check `docker compose logs web`. |
| You were logged out after changing `SECRET_KEY` | Expected. Old session cookies stop working. Log in again. |
| You want a clean database | `docker compose down -v` |
| Tests fail with an import error | Run `pytest` from the repository root, with the dev requirements installed. |

## Known limits

Posts cannot be edited or deleted. There is no pagination, no rate limiting and no HTTPS in the local setup. See the out-of-scope list in the requirements document.

## AI disclosure

If AI tools helped with this work, state it here according to your institution's academic integrity policy, and make sure you can explain every part of the code.
