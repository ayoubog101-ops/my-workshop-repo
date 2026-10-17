(function () {
  "use strict";

  var mode = "login";
  var $ = function (id) { return document.getElementById(id); };

  function api(path, options) {
    options = options || {};
    var init = {
      method: options.method || "GET",
      credentials: "same-origin",
      headers: {}
    };
    if (options.body) {
      init.headers["Content-Type"] = "application/json";
      init.body = JSON.stringify(options.body);
    }
    return fetch(path, init).then(function (res) {
      return res.json().catch(function () { return {}; }).then(function (data) {
        if (!res.ok) {
          var err = new Error(data.error || "Something went wrong.");
          err.status = res.status;
          throw err;
        }
        return data;
      });
    });
  }

  function formatDate(iso) {
    var d = new Date(iso);
    if (isNaN(d.getTime())) { return iso; }
    return d.toLocaleString();
  }

  function renderFeed(posts) {
    var list = $("feed");
    list.innerHTML = "";
    $("empty").hidden = posts.length > 0;
    posts.forEach(function (p) {
      var li = document.createElement("li");
      li.className = "post";
      var head = document.createElement("div");
      head.className = "post-head";
      var author = document.createElement("strong");
      author.textContent = "@" + p.author;
      var time = document.createElement("time");
      time.dateTime = p.created_at;
      time.textContent = formatDate(p.created_at);
      head.appendChild(author);
      head.appendChild(time);
      var body = document.createElement("p");
      body.textContent = p.content;
      li.appendChild(head);
      li.appendChild(body);
      list.appendChild(li);
    });
  }

  function loadFeed() {
    return api("/api/posts").then(renderFeed);
  }

  function showLoggedIn(user) {
    $("auth-card").hidden = true;
    $("composer").hidden = false;
    $("user-bar").hidden = false;
    $("current-user").textContent = "@" + user.username;
  }

  function showLoggedOut() {
    $("auth-card").hidden = false;
    $("composer").hidden = true;
    $("user-bar").hidden = true;
    $("current-user").textContent = "";
  }

  function setMode(next) {
    mode = next;
    var login = mode === "login";
    $("auth-title").textContent = login ? "Log in" : "Create account";
    $("auth-submit").textContent = login ? "Log in" : "Register";
    $("auth-switch-text").textContent = login ? "No account yet?" : "Already registered?";
    $("auth-switch").textContent = login ? "Register" : "Log in";
    $("password").autocomplete = login ? "current-password" : "new-password";
    $("auth-error").textContent = "";
  }

  $("auth-switch").addEventListener("click", function (e) {
    e.preventDefault();
    setMode(mode === "login" ? "register" : "login");
  });

  $("auth-form").addEventListener("submit", function (e) {
    e.preventDefault();
    $("auth-error").textContent = "";
    api("/api/" + mode, {
      method: "POST",
      body: { username: $("username").value, password: $("password").value }
    }).then(function (user) {
      $("auth-form").reset();
      showLoggedIn(user);
    }).catch(function (err) {
      $("auth-error").textContent = err.message;
    });
  });

  $("logout-btn").addEventListener("click", function () {
    api("/api/logout", { method: "POST" }).then(showLoggedOut);
  });

  $("post-content").addEventListener("input", function () {
    $("counter").textContent = $("post-content").value.length + " / 280";
  });

  $("post-form").addEventListener("submit", function (e) {
    e.preventDefault();
    $("post-error").textContent = "";
    api("/api/posts", {
      method: "POST",
      body: { content: $("post-content").value }
    }).then(function () {
      $("post-form").reset();
      $("counter").textContent = "0 / 280";
      return loadFeed();
    }).catch(function (err) {
      $("post-error").textContent = err.message;
      if (err.status === 401) { showLoggedOut(); }
    });
  });

  api("/api/me").then(showLoggedIn).catch(showLoggedOut);
  loadFeed();
})();
