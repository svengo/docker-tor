// variables
local tor_version = "0.4.7.13";
local repo = "svengo/tor";

{
  "kind": "pipeline",
  "name": "build",
  "steps": [
    {
      "name": "publish image (branch: ${DRONE_BRANCH})",
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
        "tags": (
           if "${DRONE_BRANCH}" == "main" then [
               "latest",
               "${DRONE_COMMIT_SHA:0:8}",
               tor_version
             ] 
           else [
               "${DRONE_BRANCH/\\//-}"
             ]
        ),
        "cache_from": [
          "svengo/tor:latest",
          "svengo/tor:%(tor_version)s" % {tor_version: tor_version},
          "svengo/tor:${DRONE_BRANCH}"
        ],
        "purge": false,
        "dry_run": true,
        "force_tag": true
      }
    },
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
