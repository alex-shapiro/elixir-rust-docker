FROM elixir:1.5

ENV RUST_VERSION="1.20.0"
ENV NODE_VERSION="8.x"
ENV KUBECTL_VERSION="v1.7.0"

RUN apt-get update && \
    apt-get install \
       ca-certificates \
       curl \
       gcc \
       libc6-dev \
       -qqy \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
ENV RUST_ARCHIVE="rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz"
ENV RUST_DOWNLOAD_URL="https://static.rust-lang.org/dist/$RUST_ARCHIVE"
RUN mkdir -p /rust \
    && cd /rust \
    && curl -fsOSL $RUST_DOWNLOAD_URL \
    && curl -s $RUST_DOWNLOAD_URL.sha256 | sha256sum -c - \
    && tar -C /rust -xzf $RUST_ARCHIVE --strip-components=1 \
    && rm $RUST_ARCHIVE \
    && ./install.sh

# Install Node.js
ENV NODE_DOWNLOAD_URL="https://deb.nodesource.com/setup_$NODE_VERSION"
RUN curl -sL $NODE_DOWNLOAD_URL | bash - \
    && apt-get install -y nodejs

# Install Docker
RUN curl -fsSL "https://get.docker.com" | sh

# Install AWS CLI
RUN apt-get update \
    && apt-get -y install python-pip python-dev build-essential \
    && pip install --upgrade pip \
    && pip install --upgrade awscli

# Install kubectl
ENV KUBECTL_DOWNLOAD_URL="https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
RUN curl -LO $KUBECTL_DOWNLOAD_URL \
    && chmod +x /kubectl \
    && mv ./kubectl /usr/local/bin/kubectl
