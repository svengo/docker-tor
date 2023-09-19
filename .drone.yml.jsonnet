// variables
local tor_version = "0.4.8.6";
local repo = "svengo/tor";

// https://community.harness.io/t/how-to-reduce-yaml-boilerplate/10534
local docker(name, branch) = {
  "name": name,
  "image": "plugins/docker",
  "pull": "if-not-exists",
  "settings": {
    "username": {
      "from_secret": "docker_username"
    },
    "password": {
      "from_secret": "docker_password"
    },
    "build_args": [
      "TOR_VERSION=%(tor_version)s" % {tor_version: tor_version}
    ],
    "repo": repo,
    "tags": 
    (
       if branch == "main" then [
           "latest",
           "${DRONE_COMMIT_SHA:0:8}",
           tor_version
         ] 
       else [
           "${DRONE_BRANCH/\\//-}"
         ]
    ),
    "cache_from":
      (
        if branch == "main" then [
          "%(repo)s:staging" % {repo: repo}
        ]
      ),
    "purge": false,
    "dry_run": false,
    "force_tag": true,
    "failure": "ignore",
  },
  "when": {
    "branch": 
      (
        if branch == "main" then 
          ["main"]
        else 
          {"exclude": ["main"]}
      ) 
    
  }
};

{
  "kind": "pipeline",
  "name": "build",
  "steps": [
    docker("build-main", "main"),
    docker("build-develop", "develop"),
    {
      "name": "send telegram notification",
      "image": "appleboy/drone-telegram",
      "settings": {
        "token": {
          "from_secret": "telegram_token"
        },
        "to": {
          "from_secret": "telegram_username"
        },
        "format": "markdown",
        "message": "{{#success build.status}} ✅ Build #{{build.number}} of `{{repo.name}}` succeeded.\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n🌐 {{ build.link }} {{else}} ❌ Build #{{build.number}} of `{{repo.name}}` failed.\n📝 Commit by {{commit.author}} on `{{commit.branch}}`:\n``` {{commit.message}} ```\n🌐 {{ build.link }} {{/success}}\n"
      },
      "trigger": {
        "status": [
          "success",
          "failure"
        ]
      }
    }
  ],
  "trigger": {
    "event": [
      "push"
    ]
  }
}
