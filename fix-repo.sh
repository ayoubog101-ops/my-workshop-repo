#!/usr/bin/env bash
# Moves the X Lite project to the repo root and removes the old starter files.
# Run from the repo root (the folder that contains xlite/xlite). It does not commit or push.

set -eu

if [ ! -d xlite/xlite/backend ]; then
  echo "Run this from the repo root, the folder that contains xlite/xlite."
  exit 1
fi

echo "1/4 Removing the old starter files..."
git rm -r -q -f --ignore-unmatch Dockerfile docker-compose.yml backend tests docs README.md .github .gitignore
rm -rf backend tests docs .github

echo "2/4 Moving the X Lite project to the repo root..."
cp -r xlite/xlite/. .
rm -rf xlite

echo "3/4 Writing the hidden files..."
mkdir -p .github/workflows

cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
  pull_request:

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
          cache-dependency-path: backend/requirements-dev.txt

      - name: Install dependencies
        run: pip install -r backend/requirements-dev.txt

      - name: Run tests
        run: pytest -v

  docker:
    name: Build image and smoke test
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t xlite:ci .

      - name: Smoke test the container
        run: |
          docker run -d --name xlite -p 8000:8000 xlite:ci
          for i in $(seq 1 20); do
            if curl -fs http://localhost:8000/api/health; then exit 0; fi
            sleep 1
          done
          docker logs xlite
          exit 1
EOF

cat > .gitignore <<'EOF'
# Secrets
.env

# Python
__pycache__/
*.py[cod]
.venv/
venv/
.pytest_cache/

# Local data
*.db
*.sqlite3
data/

# Editors and OS
.vscode/
.idea/
.DS_Store
EOF

cat > .dockerignore <<'EOF'
.git
.github
.env
.venv
__pycache__
*.pyc
.pytest_cache
tests
docs
*.db
EOF

cat > .env.example <<'EOF'
# Copy this file to .env (optional for the local demo)
# Use a long random value for anything beyond a local demo.
SECRET_KEY=replace-with-a-long-random-string
EOF

cat > .gitattributes <<'EOF'
* text=auto
*.sh text eol=lf
Dockerfile text eol=lf
EOF

echo "4/4 Staging everything..."
git add -A

echo
git status --short
echo
echo "Done. Now run:"
echo '  git commit -m "Move X Lite to repo root and fix CI"'
echo "  git push origin main"
