# docker-PyWebScrapBook

[![CI](https://github.com/vsc55/docker-PyWebScrapBook/actions/workflows/docker-image.yml/badge.svg)](https://github.com/vsc55/docker-PyWebScrapBook/actions/workflows/docker-image.yml)
[![Release](https://img.shields.io/github/v/release/vsc55/docker-PyWebScrapBook)](https://github.com/vsc55/docker-PyWebScrapBook/releases)
[![Docker Hub](https://img.shields.io/docker/v/vsc55/webscrapbook?label=docker%20hub&sort=semver)](https://hub.docker.com/r/vsc55/webscrapbook)
[![Docker Pulls](https://img.shields.io/docker/pulls/vsc55/webscrapbook)](https://hub.docker.com/r/vsc55/webscrapbook)
![Image Size](https://img.shields.io/docker/image-size/vsc55/webscrapbook/latest)
![Python](https://img.shields.io/badge/python-3.14--alpine-3776AB)
![Platform](https://img.shields.io/badge/platform-amd64%20%7C%20arm64%20%7C%20arm%20%7C%20386-0078D6)
[![License](https://img.shields.io/github/license/vsc55/docker-PyWebScrapBook)](LICENSE)
![Last Commit](https://img.shields.io/github/last-commit/vsc55/docker-PyWebScrapBook)
![Code Size](https://img.shields.io/github/languages/code-size/vsc55/docker-PyWebScrapBook)
![Top Language](https://img.shields.io/github/languages/top/vsc55/docker-PyWebScrapBook)
![Maintenance](https://img.shields.io/maintenance/yes/2026)
![Author](https://img.shields.io/badge/author-VSC55-lightgrey)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/vsc55/docker-PyWebScrapBook)
[![GitHub Stars](https://img.shields.io/github/stars/vsc55/docker-PyWebScrapBook?style=social)](https://github.com/vsc55/docker-PyWebScrapBook/stargazers)

Docker image for the backend server of the **WebScrapBook** browser extension
(a tool to capture and organize web pages), packaging
[PyWebScrapBook](https://github.com/danny0838/PyWebScrapBook) on Alpine.

* Server (PyPI): https://pypi.org/project/webscrapbook/
* Server (GitHub): https://github.com/danny0838/PyWebScrapBook
* Browser extension: https://github.com/danny0838/webscrapbook
* Docker Hub: https://hub.docker.com/r/vsc55/webscrapbook
* GitHub Container Registry: `ghcr.io/vsc55/webscrapbook`
* Releases: https://github.com/vsc55/docker-PyWebScrapBook/releases

## Create Container:
```
docker create --name PyWebScrapBook -v /dockers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
docker container start PyWebScrapBook
```
or
```
docker run -v /dockers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
```

## Docker Compose:
Basic `docker-compose.yml`:
```yaml
services:
  webapp:
    image: vsc55/webscrapbook:latest
    ports:
      - "8080:8080"
    volumes:
      - webscrapbook_data:/data
    restart: unless-stopped

volumes:
  webscrapbook_data:
```
Start it with:
```
docker compose up -d
```
See the full example (authentication, reverse proxy, HTTPS...) in
[docker-compose.yml](docker-compose.yml).

## Data layout:
Everything the server needs lives under the `/data` volume:

| Path | Description |
| --- | --- |
| `/data/store/` | The served scrapbook content. **Put your scrapbook here** (it is what the extension reads and writes). |
| `/data/.wsb/config.ini` | Generated configuration (see below). |
| `/data/.wsb/backup/` | Automatic backups created by the server. |

The `config.ini` is generated on the first run, and the container runs as an
unprivileged `wsb` user, so `/data` is `chown`ed to that user on first start.
If you use a bind mount, that host directory will change ownership accordingly.

## Usage (connect the extension):
1. Start the container and open `http://<host>:8080/` in a browser to confirm
   the server responds.
2. In the WebScrapBook extension options, go to **Backend server** and set:
   * **Backend server URL**: `http://<host>:8080/`
   * **User** / **Password**: only if you enabled authentication (see below).
3. You can now capture pages into the server and browse the scrapbook remotely.

## Configuration (environment variables):
The container generates `/data/.wsb/config.ini` on first run and re-applies the
variables below on **every** boot (the environment is the source of truth for
these keys). Any other key can still be edited by hand in `config.ini`.

| Variable | config.ini key | Description |
| --- | --- | --- |
| `HTTP_PORT` | `server.port` | Listening port (default `8080`). |
| `WSB_AUTH_USER` | `auth.user` | Enables HTTP Basic auth when set. |
| `WSB_AUTH_PASSWORD` | `auth.pw` | Password (stored hashed). |
| `WSB_AUTH_PERMISSION` | `auth.permission` | `all` (default) or `read` (read-only). |
| `WSB_ALLOWED_X_FOR` | `app.allowed_x_for` | Trusted `X-Forwarded-For` values (reverse proxy). |
| `WSB_ALLOWED_X_PROTO` | `app.allowed_x_proto` | Trusted `X-Forwarded-Proto` values. |
| `WSB_ALLOWED_X_HOST` | `app.allowed_x_host` | Trusted `X-Forwarded-Host` values. |
| `WSB_ALLOWED_X_PORT` | `app.allowed_x_port` | Trusted `X-Forwarded-Port` values. |
| `WSB_ALLOWED_X_PREFIX` | `app.allowed_x_prefix` | Trusted `X-Forwarded-Prefix` values. |
| `WSB_SSL_ON` | `server.ssl_on` | `true` to enable HTTPS. |
| `WSB_SSL_CERT` / `WSB_SSL_KEY` | `server.ssl_cert` / `ssl_key` | Cert/key files, relative to `/data`. |
| `WSB_SSL_PW` | `server.ssl_pw` | Key passphrase (if any). |
| `WSB_APP_NAME` | `app.name` | Site title. |
| `WSB_THEME` | `app.theme` | Theme name. |
| `WSB_LOCALE` | `app.locale` | Interface locale (e.g. `en`, `zh_TW`). |

> **Port:** `HTTP_PORT` is the port *inside* the container. If you change it,
> update the published port to match, e.g. `HTTP_PORT=9000` with `-p 9000:9000`.

> **HTTPS:** with an empty cert/key it uses an "adhoc" certificate, which
> requires the `webscrapbook[adhoc_ssl]` extra in the image. For real usage,
> mount your cert/key under `/data` (or terminate TLS at a reverse proxy).

## Hosting on a subpath:
To serve PyWebScrapBook under a subpath (e.g. `https://example.com/scrapbook/`),
set `WSB_ALLOWED_X_PREFIX=1` and make your reverse proxy forward the
`X-Forwarded-Prefix` header. Example with nginx:
```nginx
location /scrapbook/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header X-Forwarded-Prefix /scrapbook;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-Host   $host;
}
```
The app (via `ProxyFix`) then builds its URLs with the `/scrapbook` prefix, so
no image changes are needed. Set the matching `WSB_ALLOWED_X_*` variables for
any other forwarded headers your proxy sends.

## Image tags:
Released images are published to both Docker Hub (`vsc55/webscrapbook`) and GHCR
(`ghcr.io/vsc55/webscrapbook`):
* `latest` — the most recent published release.
* `X.Y.Z` — a specific WebScrapBook version (e.g. `2.9.0`), recommended for
  reproducible deployments.
* `test` — **GHCR only**; a rolling build from the latest `master` commit
  (amd64), for testing. Not for production.

## Versioning & releases:
This project has two independent versions:
* **Product** — the WebScrapBook version, used as the image tag (e.g. `2.9.0`).
* **Image** — this repository's own version (see [CHANGELOG.md](CHANGELOG.md)),
  bumped only when the Docker setup itself changes.

Pushing a version tag builds and publishes the image (Docker Hub + GHCR) and
creates a [GitHub Release](https://github.com/vsc55/docker-PyWebScrapBook/releases)
with `docker pull` instructions and the WebScrapBook changelog for that version.
Image-level changes are listed in the release only when they happened for that
version.

## Update:
```
docker compose pull && docker compose up -d
```
or, without Compose:
```
docker pull vsc55/webscrapbook:latest
docker rm -f PyWebScrapBook
# then re-create the container (see "Create Container")
```

## Version PyWebScrapBook and Python:

| WebScrapBook | Python base image |
| --- | --- |
| 2.9.0 → latest | `python:3.14-alpine` |
| 2.8.0 – 2.8.2 | `python:3.13.12-alpine` |
| 2.6.0 – 2.7.2 | `python:3.13.3-alpine` |
| 2.5.1 – 2.5.3 | `python:3.13.1-alpine` |
| 1.1.0 – 2.5.0 | `python:3.10.1-alpine` |
| 0.15.0 – 1.0.0 | `python:3.7.7-alpine` |
| 0.8.0 – 0.14.4 | `python:3.7.3-alpine` |

## Arch Support
* linux/386
* linux/amd64
* linux/arm64/v8
* linux/arm/v7
* linux/arm/v6

## Links:
* Changelog: [CHANGELOG.md](CHANGELOG.md)
* License: [LICENSE](LICENSE)

## Star History

<a href="https://www.star-history.com/?repos=vsc55%2Fdocker-PyWebScrapBook&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=vsc55/docker-PyWebScrapBook&type=date&theme=dark&legend=top-left&sealed_token=ckw3Qetu_FDo4yK_r7ARz35VaJ1SYXUk4kxaSC8_hU6Up3oJfduWGI0BJK-6efLlJ5d_XpPo8fTU9I2cfA9xYZEiiQ3OkSvy5k_nq6PkJ_Yhyri0MnKeG9SCg6wzp3LU4PeuHlY3QB0bcJd-D4zNPGb3AALFJHTOU0DHbEwT0BPFZQgh3uvXMtWI25Za" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=vsc55/docker-PyWebScrapBook&type=date&legend=top-left&sealed_token=ckw3Qetu_FDo4yK_r7ARz35VaJ1SYXUk4kxaSC8_hU6Up3oJfduWGI0BJK-6efLlJ5d_XpPo8fTU9I2cfA9xYZEiiQ3OkSvy5k_nq6PkJ_Yhyri0MnKeG9SCg6wzp3LU4PeuHlY3QB0bcJd-D4zNPGb3AALFJHTOU0DHbEwT0BPFZQgh3uvXMtWI25Za" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=vsc55/docker-PyWebScrapBook&type=date&legend=top-left&sealed_token=ckw3Qetu_FDo4yK_r7ARz35VaJ1SYXUk4kxaSC8_hU6Up3oJfduWGI0BJK-6efLlJ5d_XpPo8fTU9I2cfA9xYZEiiQ3OkSvy5k_nq6PkJ_Yhyri0MnKeG9SCg6wzp3LU4PeuHlY3QB0bcJd-D4zNPGb3AALFJHTOU0DHbEwT0BPFZQgh3uvXMtWI25Za" />
 </picture>
</a>
