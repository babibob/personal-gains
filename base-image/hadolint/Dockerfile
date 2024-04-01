FROM hadolint/hadolint:latest-alpine

RUN apk add --no-cache --update docker-cli-compose yamllint  \
    && mkdir -vpm 0644 /opt/yamllint/

COPY ./yamllint.conf /opt/yamllint/

ENV YAMLLINT_CONFIG_FILE=/opt/yamllint/yamllint.conf