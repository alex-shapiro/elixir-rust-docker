FROM erlang:20.1

ENV ELIXIR_VERSION="v1.5.2"
ENV RUST_VERSION="1.22.0"
ENV NODE_VERSION="8.x"
ENV LANG="C.UTF-8"

RUN apt-get update && \
    apt-get install \
       ca-certificates \
       curl \
       gcc \
       libc6-dev \
       -qqy \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Elixir
RUN set -xe \
    && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
    && ELIXIR_DOWNLOAD_SHA256="7317b7a9d3b5bef2b5cd56de738f2b37fd4111e24efbe71a3e39bea1b702ff6c" \
    && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
    && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/local/src/elixir \
    && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
    && rm elixir-src.tar.gz \
    && cd /usr/local/src/elixir \
    && make install clean

# Install Rust
RUN RUST_ARCHIVE="rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz" && \
    RUST_DOWNLOAD_URL="https://static.rust-lang.org/dist/$RUST_ARCHIVE" && \
    mkdir -p /rust \
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

# Install Google Cloud SDK
# 1. Add the Cloud SDK distribution URI as a package source
# 2. Import the Google Cloud Platform public key
# 3. Update the package list and install the Cloud SDK
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y install google-cloud-sdk \
    && apt-get -y install kubectl
