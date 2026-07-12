FROM python:3.14-alpine

LABEL version="1.2" maintainer="vsc55@cerebelum.net" description="Docker PyWebScrapBook"

ARG wsb_ver
ENV wsb_ver=${wsb_ver}

RUN apk add --no-cache --virtual .build-deps gcc libc-dev openssl-dev libffi-dev libxslt-dev; \
	apk add --no-cache bash libxslt curl su-exec; \
	pip install --no-cache-dir --upgrade pip; \
	if [ "$wsb_ver" = "" ] || [ "$wsb_ver" = "dev" ]; \
	then \
		pip install --no-cache-dir webscrapbook; \
	else \
		pip install --no-cache-dir webscrapbook==${wsb_ver}; \
	fi; \
	apk del .build-deps; \
	addgroup -S wsb && adduser -S -G wsb wsb;

WORKDIR /
COPY --chown=root:root ["entrypoint.sh", "run_wsb.sh", "health_check.sh", "apply_config.py", "./"]

#Fix, hub.docker.com auto buils
RUN chmod +x /*.sh

# Configurable environment variables (applied to config.ini on every boot):
#
#   Build-time:
#     wsb_ver              WebScrapBook version to install (empty/"dev" = latest PyPI).
#
#   Runtime:
#     HTTP_PORT            TCP port the server listens on (also the EXPOSE'd port).
#
#   Runtime - authentication ([auth]); enabled when WSB_AUTH_USER is set:
#     WSB_AUTH_USER        HTTP Basic auth user name.
#     WSB_AUTH_PASSWORD    Plain password; stored hashed via werkzeug.
#     WSB_AUTH_PERMISSION  "all" (default) or "read" (read-only).
#
#   Runtime - reverse proxy ([app]); number of trusted proxy header values:
#     WSB_ALLOWED_X_FOR / _PROTO / _HOST / _PORT / _PREFIX   (default 0)
#
#   Runtime - HTTPS ([server]):
#     WSB_SSL_ON           "true" to enable TLS (empty cert/key = adhoc,
#                          needs the webscrapbook[adhoc_ssl] extra).
#     WSB_SSL_CERT         Cert file, path relative to /data.
#     WSB_SSL_KEY          Key file, path relative to /data.
#     WSB_SSL_PW           Key passphrase (if any).
#
#   Runtime - appearance ([app]):
#     WSB_APP_NAME         Site title.
#     WSB_THEME            Theme name.
#     WSB_LOCALE           Interface locale (e.g. en, zh_TW).
ENV HTTP_PORT=8080

# Persistent data: WebScrapBook config (/data/.wsb), the served store (/data/store)
# and, optionally, a user-provided /data/run_wsb.sh that overrides the boot script.
VOLUME ["/data"]
EXPOSE ${HTTP_PORT}/tcp

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s CMD /health_check.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
