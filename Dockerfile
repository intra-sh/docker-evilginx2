ARG BUILD_RFC3339="1970-01-01T00:00:00Z"
ARG VERSION="v3.3.0"
ARG EVILGINX_BIN="/bin/evilginx"

FROM golang:alpine AS build-alpine

ENV GITHUB_USER="kgretzky"
ENV EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/evilginx2"
ENV INSTALL_PACKAGES="git make gcc musl-dev go"
ENV PROJECT_DIR="${GOPATH}/src/${EVILGINX_REPOSITORY}"
ENV EVILGINX_BIN="${EVILGINX_BIN}"

RUN mkdir -p ${GOPATH}/src/github.com/${GITHUB_USER} \
    && apk add --no-cache ${INSTALL_PACKAGES} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone https://github.com/${GITHUB_USER}/evilginx2 
    
RUN set -ex \
        && cd ${PROJECT_DIR}/ && go get ./... && make \
		&& cp ${PROJECT_DIR}/build/evilginx ${EVILGINX_BIN}

FROM golang:bookworm

ENV EVILGINX_BIN="${EVILGINX_BIN}"

COPY --from=build-alpine ${EVILGINX_BIN} ${EVILGINX_BIN}

COPY ./docker-entrypoint.sh /opt/
RUN chmod +x /opt/docker-entrypoint.sh
		
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
EXPOSE 443

STOPSIGNAL SIGKILL

LABEL org.label-schema.name="Evilginx2 Docker" \
  org.label-schema.description="Evilginx2 Docker Build" \
  org.label-schema.version=$VERSION \
  org.label-schema.schema-version="1.0"
