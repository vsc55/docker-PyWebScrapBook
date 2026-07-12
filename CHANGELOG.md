# Changelog

All notable changes to this Docker image are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2] - 2026-07-12

Targets **WebScrapBook 2.9.0** on **python:3.14-alpine**.

### Added

- Configuration via environment variables, applied to `config.ini` on every
  boot (the environment is the source of truth for the managed keys):
  - Authentication: `WSB_AUTH_USER`, `WSB_AUTH_PASSWORD` (stored hashed),
    `WSB_AUTH_PERMISSION` (`all`/`read`).
  - Reverse proxy: `WSB_ALLOWED_X_FOR`, `WSB_ALLOWED_X_PROTO`,
    `WSB_ALLOWED_X_HOST`, `WSB_ALLOWED_X_PORT`, `WSB_ALLOWED_X_PREFIX`.
  - HTTPS: `WSB_SSL_ON`, `WSB_SSL_CERT`, `WSB_SSL_KEY`, `WSB_SSL_PW`.
  - Appearance: `WSB_APP_NAME`, `WSB_THEME`, `WSB_LOCALE`.
- `apply_config.py`: idempotent config writer (only re-hashes the auth password
  when it actually changes; removes the managed `[auth "docker"]` section when
  `WSB_AUTH_USER` is unset).
- The server now runs as an unprivileged `wsb` user (privileges are dropped with
  `su-exec` after the entrypoint fixes the volume ownership).
- Documented the environment variables in the `Dockerfile` and both
  `docker-compose*` examples.
- Expanded the `README.md`: data layout, extension usage, Docker Compose
  example, configuration table, subpath hosting (reverse proxy +
  `WSB_ALLOWED_X_PREFIX`), image tags, update steps, and the version/arch
  tables aligned with the CI workflow.
- CI: `upstream-release` workflow that polls PyPI daily and, when a new
  WebScrapBook version appears, creates the matching tag (which triggers the
  `ci` build & publish). Requires a `TOKEN_WEBSCRAPBOOK` PAT secret so the tag
  push fires `ci`.

### Changed

- Bumped base image to `python:3.14-alpine` (WebScrapBook 2.9.0).
- `run_wsb.sh` and `entrypoint.sh` now `exec` the final process so it becomes
  PID 1 and shuts down cleanly on `SIGTERM` (`docker stop`).
- `health_check.sh` now follows `WSB_SSL_ON` and switches to `https` (with `-k`)
  when TLS is enabled.
- Image `LABEL version` updated to `1.2`.
- CI: rebuilt the GitHub Actions workflow into two jobs. `test` builds an amd64
  image and runs a smoke test (the container must boot and serve) on every push
  to `master`, pull request and manual run; all `docker/*` actions were updated
  to their current majors. `publish` builds and pushes the multi-arch image to
  Docker Hub only on a version tag and only after `test` passes.
- CI: bumped `actions/checkout` to v5 (Node.js 24) to clear the Node.js 20
  deprecation warning.

### Fixed

- Removed `--platform=$BUILDPLATFORM` from `FROM`, which forced the builder's
  architecture and broke multi-arch builds.
- Corrected the inverted condition in the ownership fix that previously
  prevented `chown` from ever running.
- CI: `build_args` → `build-args` in the publish step. The typo silently
  dropped the argument, so published images installed WebScrapBook `latest`
  regardless of the release tag; the tagged version is now actually built.

### Removed

- Docker Hub autobuild hooks (`hooks/build`, `hooks/post_push`). Publishing is
  now handled by the GitHub Actions `ci` workflow; keeping the hooks (with
  Docker Hub autobuild enabled) would publish the image a second time. Remember
  to disable the Automated Build on Docker Hub as well.
- `MODE_RUN` environment variable (declared but never used).
- `--squash` flag from `build.sh` (experimental, fails on modern builders).
- `apk upgrade --no-cache` from the build (kept for reproducibility; base image
  updates handle security patches).
