import os
import re
import sqlite3
from datetime import datetime, timezone

from flask import Flask, g, jsonify, request, session
from werkzeug.security import check_password_hash, generate_password_hash

USERNAME_RE = re.compile(r"^[A-Za-z0-9_]{3,20}$")
MAX_POST_LENGTH = 280
MIN_PASSWORD_LENGTH = 8

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE COLLATE NOCASE,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC, id DESC);
"""


def utc_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def create_app(test_config=None):
    app = Flask(__name__, static_folder="static", static_url_path="")
    app.config.update(
        SECRET_KEY=os.environ.get("SECRET_KEY", "dev-only-change-me"),
        DATABASE=os.environ.get("DATABASE_PATH", "/data/app.db"),
        SESSION_COOKIE_HTTPONLY=True,
        SESSION_COOKIE_SAMESITE="Lax",
    )
    if test_config:
        app.config.update(test_config)

    db_dir = os.path.dirname(app.config["DATABASE"])
    if db_dir:
        os.makedirs(db_dir, exist_ok=True)

    def get_db():
        if "db" not in g:
            g.db = sqlite3.connect(app.config["DATABASE"])
            g.db.row_factory = sqlite3.Row
            g.db.execute("PRAGMA foreign_keys = ON")
        return g.db

    @app.teardown_appcontext
    def close_db(_exc):
        db = g.pop("db", None)
        if db is not None:
            db.close()

    with app.app_context():
        get_db().executescript(SCHEMA)
        get_db().commit()

    def error(message, status):
        return jsonify({"error": message}), status

    def current_user():
        uid = session.get("user_id")
        if uid is None:
            return None
        return get_db().execute(
            "SELECT id, username FROM users WHERE id = ?", (uid,)
        ).fetchone()

    @app.get("/")
    def index():
        return app.send_static_file("index.html")

    @app.get("/api/health")
    def health():
        return jsonify({"status": "ok"})

    @app.post("/api/register")
    def register():
        data = request.get_json(silent=True) or {}
        username = str(data.get("username", "")).strip()
        password = str(data.get("password", ""))
        if not USERNAME_RE.match(username):
            return error("Username must be 3 to 20 letters, numbers or underscores.", 400)
        if len(password) < MIN_PASSWORD_LENGTH:
            return error(f"Password must be at least {MIN_PASSWORD_LENGTH} characters.", 400)
        db = get_db()
        try:
            cur = db.execute(
                "INSERT INTO users (username, password_hash, created_at) VALUES (?, ?, ?)",
                (username, generate_password_hash(password), utc_now()),
            )
            db.commit()
        except sqlite3.IntegrityError:
            return error("That username is already taken.", 409)
        session.clear()
        session["user_id"] = cur.lastrowid
        return jsonify({"id": cur.lastrowid, "username": username}), 201

    @app.post("/api/login")
    def login():
        data = request.get_json(silent=True) or {}
        username = str(data.get("username", "")).strip()
        password = str(data.get("password", ""))
        row = get_db().execute(
            "SELECT id, username, password_hash FROM users WHERE username = ?",
            (username,),
        ).fetchone()
        if row is None or not check_password_hash(row["password_hash"], password):
            return error("Invalid username or password.", 401)
        session.clear()
        session["user_id"] = row["id"]
        return jsonify({"id": row["id"], "username": row["username"]})

    @app.post("/api/logout")
    def logout():
        session.clear()
        return jsonify({"status": "logged out"})

    @app.get("/api/me")
    def me():
        user = current_user()
        if user is None:
            return error("Not authenticated.", 401)
        return jsonify({"id": user["id"], "username": user["username"]})

    @app.get("/api/posts")
    def list_posts():
        rows = get_db().execute(
            """
            SELECT posts.id, posts.content, posts.created_at, users.username AS author
            FROM posts JOIN users ON users.id = posts.user_id
            ORDER BY posts.created_at DESC, posts.id DESC
            LIMIT 200
            """
        ).fetchall()
        return jsonify([dict(r) for r in rows])

    @app.post("/api/posts")
    def create_post():
        user = current_user()
        if user is None:
            return error("You must be logged in to post.", 401)
        data = request.get_json(silent=True) or {}
        content = str(data.get("content", "")).strip()
        if not content:
            return error("Post cannot be empty.", 400)
        if len(content) > MAX_POST_LENGTH:
            return error(f"Post cannot be longer than {MAX_POST_LENGTH} characters.", 400)
        db = get_db()
        created_at = utc_now()
        cur = db.execute(
            "INSERT INTO posts (user_id, content, created_at) VALUES (?, ?, ?)",
            (user["id"], content, created_at),
        )
        db.commit()
        return (
            jsonify(
                {
                    "id": cur.lastrowid,
                    "content": content,
                    "created_at": created_at,
                    "author": user["username"],
                }
            ),
            201,
        )

    return app
