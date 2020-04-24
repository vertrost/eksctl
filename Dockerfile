FROM alpine:edge as downloads
WORKDIR /downloads
ENV EKSCTL_VERSION=0.17.0
RUN apk -uv add --no-cache wget tar
RUN wget "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" \
   && tar -zxvf "eksctl_$(uname -s)_amd64.tar.gz" \
   && chmod +x eksctl

FROM python:3.6-alpine3.10 as eksctl

VOLUME /root/.aws
ENV AWS_CLI_VERSION=1.18.45
ENV EKSCTL_VERSION=0.17.0
ENV AWS_CLI_VERSION=${AWS_CLI_VERSION} \
    EKSCTL_VERSION=${EKSCTL_VERSION}
RUN apk -uv add --no-cache groff jq less bash && \
    pip install --no-cache-dir awscli==$AWS_CLI_VERSION

COPY --from=downloads  /downloads/eksctl /usr/local/bin

FROM eksctl as eksctl-kubectl

RUN apk add --update ca-certificates bash gnupg jq \
  && apk add --update -t deps curl gettext \
  && rm -rf /var/cache/apk/* 
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl
