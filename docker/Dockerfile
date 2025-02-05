FROM debian:12

RUN apt-get update && apt-get install -y \
  curl \
  jq \
  git \
  bash \
  libcurl4-openssl-dev \
  libicu72

RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz && \
    mkdir /actions-runner && \
    tar -xzf /actions-runner.tar.gz -C /actions-runner && \
    rm /actions-runner.tar.gz && \
    useradd runner -s /bin/bash

WORKDIR /actions-runner

COPY entrypoint.sh entrypoint.sh

RUN  chown -R runner:runner /actions-runner && \
     chmod 550 entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]