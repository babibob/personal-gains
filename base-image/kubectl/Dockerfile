# vim: filetype=dockerfile:
FROM busybox:1.36 as downloader

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG KUBECTL_VERSION 1.28.5
ARG HELM_VERSION 3.13.3
ARG HELMFILE_VERSION 0.160.0

ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz

WORKDIR /go

# hadolint ignore=SC2016
RUN set -eux; \
    wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl; \
    wget -qO - https://get.helm.sh/${HELM_FILENAME} | tar xz; \
    wget -qO helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64; \
    chmod -v a+x kubectl helmfile

FROM alpine:3.18

RUN apk --no-cache add --virtual .deps \
    bash \
    curl \
    file \
    gawk \
    gettext \
    jq \
    ncurses

COPY --from=downloader /go/kubectl /go/linux-amd64/helm /go/helmfile /usr/bin/

COPY scripts/kubelogin.sh scripts/hooklog.sh /usr/local/bin/

