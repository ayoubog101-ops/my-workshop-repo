import sqlite3


def test_register_creates_account_and_logs_in(client, register):
    res = register()
    assert res.status_code == 201
    assert res.get_json()["username"] == "alice"
    assert client.get("/api/me").status_code == 200


def test_password_is_hashed_in_database(app, register):
    register(password="supersecret1")
    con = sqlite3.connect(app.config["DATABASE"])
    stored = con.execute("SELECT password_hash FROM users").fetchone()[0]
    con.close()
    assert stored != "supersecret1"
    assert "supersecret1" not in stored
    assert stored.startswith(("scrypt:", "pbkdf2:"))


def test_duplicate_username_rejected_case_insensitive(client, register):
    register("alice")
    client.post("/api/logout")
    res = register("ALICE")
    assert res.status_code == 409


def test_register_validates_input(client):
    bad_name = client.post("/api/register", json={"username": "a!", "password": "password123"})
    short_pw = client.post("/api/register", json={"username": "bob", "password": "short"})
    assert bad_name.status_code == 400
    assert short_pw.status_code == 400


def test_login_success_and_logout(client, register):
    register()
    client.post("/api/logout")
    assert client.get("/api/me").status_code == 401
    res = client.post("/api/login", json={"username": "alice", "password": "password123"})
    assert res.status_code == 200
    assert client.get("/api/me").status_code == 200
    client.post("/api/logout")
    assert client.get("/api/me").status_code == 401


def test_login_wrong_password(client, register):
    register()
    client.post("/api/logout")
    res = client.post("/api/login", json={"username": "alice", "password": "wrongpass1"})
    assert res.status_code == 401


def test_login_unknown_user_gives_same_error(client):
    res = client.post("/api/login", json={"username": "ghost", "password": "whatever123"})
    assert res.status_code == 401
    assert res.get_json()["error"] == "Invalid username or password."
