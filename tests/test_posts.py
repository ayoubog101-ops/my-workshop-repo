from app import create_app


def test_create_post_requires_authentication(client):
    res = client.post("/api/posts", json={"content": "hello"})
    assert res.status_code == 401


def test_feed_is_public(client):
    assert client.get("/api/posts").status_code == 200


def test_create_post_appears_in_feed_with_author_and_date(client, register):
    register()
    res = client.post("/api/posts", json={"content": "Hello world"})
    assert res.status_code == 201
    feed = client.get("/api/posts").get_json()
    assert len(feed) == 1
    assert feed[0]["author"] == "alice"
    assert feed[0]["content"] == "Hello world"
    assert feed[0]["created_at"]


def test_feed_shows_all_users_newest_first(client, register):
    register("alice")
    client.post("/api/posts", json={"content": "first"})
    client.post("/api/logout")
    register("bob")
    client.post("/api/posts", json={"content": "second"})
    client.post("/api/posts", json={"content": "third"})
    feed = client.get("/api/posts").get_json()
    assert [p["content"] for p in feed] == ["third", "second", "first"]
    assert {p["author"] for p in feed} == {"alice", "bob"}


def test_empty_and_too_long_posts_rejected(client, register):
    register()
    assert client.post("/api/posts", json={"content": "   "}).status_code == 400
    assert client.post("/api/posts", json={"content": "x" * 281}).status_code == 400
    assert client.post("/api/posts", json={"content": "x" * 280}).status_code == 201


def test_html_is_stored_as_plain_text(client, register):
    register()
    client.post("/api/posts", json={"content": "<script>alert(1)</script>"})
    feed = client.get("/api/posts").get_json()
    assert feed[0]["content"] == "<script>alert(1)</script>"


def test_data_persists_across_app_restart(tmp_path):
    config = {"TESTING": True, "DATABASE": str(tmp_path / "p.db"), "SECRET_KEY": "k"}
    first = create_app(config).test_client()
    first.post("/api/register", json={"username": "alice", "password": "password123"})
    first.post("/api/posts", json={"content": "still here"})

    second = create_app(config).test_client()
    feed = second.get("/api/posts").get_json()
    assert feed[0]["content"] == "still here"
    login = second.post("/api/login", json={"username": "alice", "password": "password123"})
    assert login.status_code == 200


def test_index_page_served(client):
    res = client.get("/")
    assert res.status_code == 200
    assert b"X Lite" in res.data
