#!/bin/bash

PORT=${HTTP_PORT:-8080}

# Match the scheme to the SSL setting so the check works with HTTPS too.
# -k lets the probe accept self-signed certificates (e.g. the adhoc cert).
case "${WSB_SSL_ON,,}" in
	1|true|on|yes) SCHEME=https; CURL_OPTS=(-k) ;;
	*)             SCHEME=http;  CURL_OPTS=() ;;
esac

curl -sf "${CURL_OPTS[@]}" "${SCHEME}://localhost:${PORT}" > /dev/null || exit 1
exit 0
