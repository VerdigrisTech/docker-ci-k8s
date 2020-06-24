FROM debian:buster-slim AS builder

ARG DOCKER_VERSION=19.03.11
ARG KUBECTL_VERSION=1.18.3
ARG HELM_VERSION=3.2.2

WORKDIR /tmp
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar xvz
RUN curl -fsSLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz
RUN curl -fsSL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
RUN chmod +x ./kubectl ./jq

FROM alpine:latest
RUN apk --no-cache add ca-certificates curl git ssh
COPY --from=builder /tmp/docker/docker /usr/bin/
COPY --from=builder /tmp/kubectl /usr/bin/
COPY --from=builder /tmp/linux-amd64/helm /usr/bin/
COPY --from=builder /tmp/jq /usr/bin/
CMD [ "/bin/sh" ]
