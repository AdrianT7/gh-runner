FROM debian:12

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  apt-utils \
  bash \
  curl \
  git \
  jq \
  libcurl4-openssl-dev \
  libicu72

# Install GitHub Runner
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz && \
  mkdir /actions-runner && \
  tar -xzf /actions-runner.tar.gz -C /actions-runner && \
  rm /actions-runner.tar.gz && \
  useradd runner -s /bin/bash -d /actions-runner

# Install Ansible
RUN apt-get install -y ansible

# Install Terraform
RUN apt-get install -y \
  gnupg \
  software-properties-common && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg |\
  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |\
  tee /etc/apt/sources.list.d/hashicorp.list >/dev/null && \
  apt-get update && apt-get install -y terraform

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
apt-get install apt-transport-https --yes && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" |\
tee /etc/apt/sources.list.d/helm-stable-debian.list && \
apt-get update && apt-get install -y helm

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /actions-runner

COPY entrypoint.sh entrypoint.sh

RUN  chown -R runner:runner /actions-runner && \
     chmod 550 entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]