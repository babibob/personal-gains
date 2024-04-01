FROM python:3.10-slim-bookworm

ENV VERSION=9.2.0 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN mkdir -vpm 0600 /opt/ansible/
WORKDIR /opt/ansible/
COPY ./playbooks ./playbooks
COPY ./.ansible-lint.yml .


RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        git \
        curl \
        build-essential \
        jq \
        unzip \
        libffi-dev \
        libssl-dev \
        apt-utils  \
        python3-setuptools \
        python3-wheel \
        sshpass \
    && pip install --upgrade pip \
    && pip3 install ansible=="$VERSION" \
        cryptography \
        ansible-lint \
        boto3 \
        botocore \
    && python3 -m pip install 'netaddr<1.0' \
    && ansible-galaxy collection install --no-cache ansible.posix \
    && ansible-galaxy collection install --no-cache chocolatey.chocolatey \
    && ansible-galaxy collection install --no-cache community.windows \
    && ansible-galaxy collection install --no-cache community.general \
    && ansible-galaxy collection install --no-cache community.aws \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc \
    && rm -Rf /usr/share/man \
    && apt-get clean

ENV ANSIBLE_FORCE_COLOR=True \
    ANSIBLE_STDOUT_CALLBACK=yaml \
    ANSIBLE_CALLBACKS_ENABLED=yaml \
    ANSIBLE_BECOME=True \
    ANSIBLE_REMOTE_USER=gitlab-runner \
    ANSIBLE_PRIVATE_KEY_FILE=~/.ssh/id_rsa \
    ANSIBLE_PIPELINING=True \
    ANSIBLE_DIFF_ALWAYS=True \
    ANSIBLE_HOST_KEY_CHECKING=False \
    ANSIBLE_RETRY_FILES_ENABLED=False \
    ANSIBLE_DEPRECATION_WARNINGS=False \
    ANSIBLE_PORT=22 \
    ANSIBLE_PYTHON_INTERPRETER=auto_silent
