FROM --platform=$BUILDPLATFORM python:3.13.3-alpine

LABEL version="1.1" maintainer="vsc55@cerebelum.net" description="Docker PyWebScrapBook"

ARG wsb_ver
ENV wsb_ver=${wsb_ver}

RUN apk upgrade --no-cache; \
	apk add --no-cache --virtual .build-deps gcc libc-dev openssl-dev libffi-dev libxslt-dev; \
    apk add --no-cache bash libxslt curl; \
	pip install --no-cache-dir --upgrade pip; \
	if [ "$wsb_ver" = "" -o "$wsb_ver" = "dev" ] ; \
	then \
		pip install --no-cache-dir webscrapbook; \
	else \
		pip install --no-cache-dir webscrapbook==${wsb_ver}; \
	fi; \
	apk del .build-deps;

WORKDIR /
COPY --chown=root:root ["entrypoint.sh", "run_wsb.sh", "health_check.sh", "./"]

#Fix, hub.docker.com auto buils
RUN chmod +x /*.sh

ENV HTTP_PORT=8080 MODE_RUN=production

VOLUME ["/data"]
EXPOSE ${HTTP_PORT}/tcp

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s CMD /health_check.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
