FROM debian:buster-slim AS builder

ARG DOCKER_VERSION=20.10.8
ARG KUBECTL_VERSION=1.21.3
ARG HELM_VERSION=3.6.3
ARG YQ_VERSION=4.12.0
ARG JQ_VERSION=1.6

WORKDIR /tmp
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar xvz
RUN curl -fsSLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz
RUN curl -fsSL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o yq
RUN curl -fsSL https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -o jq
RUN chmod +x ./kubectl ./yq ./jq

FROM alpine:latest
RUN apk --no-cache add ca-certificates curl git openssh python3 py-pip
COPY --from=builder /tmp/docker/docker /usr/bin/
COPY --from=builder /tmp/kubectl /usr/bin/
COPY --from=builder /tmp/linux-amd64/helm /usr/bin/
COPY --from=builder /tmp/yq /usr/bin/
COPY --from=builder /tmp/jq /usr/bin/
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN pip install pyyaml
CMD [ "/bin/sh" ]
