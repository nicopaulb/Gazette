FROM alpine:3.20

ARG PB_VERSION=0.40.6
ARG TARGETARCH=amd64

RUN apk add --no-cache ca-certificates unzip wget \
    && cd /tmp \
    && wget -q https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_${TARGETARCH}.zip \
    && wget -q https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/checksums.txt \
    && grep " pocketbase_${PB_VERSION}_linux_${TARGETARCH}.zip$" checksums.txt | sha256sum -c - \
    && mkdir -p /pb/pb_data \
    && unzip pocketbase_${PB_VERSION}_linux_${TARGETARCH}.zip pocketbase -d /pb \
    && rm -f /tmp/* \
    && adduser -D -H -u 1000 pb \
    && chown -R pb:pb /pb/pb_data

USER pb
EXPOSE 8090
VOLUME /pb/pb_data

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/pb/pb_data"]
