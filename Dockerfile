FROM ubuntu:16.04

## Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io

## Install Kubectl
RUN export RELEASE=`curl -sSfL "https://storage.googleapis.com/kubernetes-release/release/stable.txt"` && \
    curl -sSfL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

## Install bx and needed plugins
RUN curl -sL https://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/latest/Bluemix_CLI_amd64.tar.gz | tar -xvzC ~/ && \
    ~/Bluemix_CLI/install_bluemix_cli && \
    bx plugin install container-registry -f -r Bluemix && \
    bx plugin install container-service -f -r Bluemix

ENV CR_URL="registry.ng.bluemix.net"
ENV DOCKERFILE="."

COPY deploy.sh /

VOLUME /data

WORKDIR /data

CMD /deploy.sh
