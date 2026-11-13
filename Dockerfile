FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG OTP_VERSION
ARG ELIXIR_VERSION=1.10.4

ENV ERLANG_PREFIX=/opt/erlang
ENV ELIXIR_PREFIX=/opt/elixir
ENV PATH=/opt/elixir/bin:/opt/erlang/bin:${PATH}
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    ca-certificates \
    curl \
    git \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libncurses5-dev \
    libpng-dev \
    libssl-dev \
    libwxgtk3.0-gtk3-dev \
    m4 \
    make \
    perl \
    python3 \
    python-is-python3 \
    rsync \
    zip \
    unixodbc-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    test -n "${OTP_VERSION}"; \
    curl --fail --show-error --location \
      --connect-timeout 15 \
      --max-time 300 \
      --retry 3 \
      --retry-delay 5 \
      --retry-connrefused \
      "https://github.com/erlang/otp/archive/refs/tags/OTP-${OTP_VERSION}.tar.gz" \
      -o /tmp/otp.tar.gz; \
    mkdir -p /tmp/otp-src; \
    tar -xzf /tmp/otp.tar.gz -C /tmp/otp-src --strip-components=1; \
    cd /tmp/otp-src; \
    ./otp_build autoconf; \
    ./configure --prefix="${ERLANG_PREFIX}"; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/otp-src /tmp/otp.tar.gz

RUN set -eux; \
    curl --fail --show-error --location \
      --connect-timeout 15 \
      --max-time 300 \
      --retry 3 \
      --retry-delay 5 \
      --retry-connrefused \
      "https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip" \
      -o /tmp/elixir.zip; \
    mkdir -p "${ELIXIR_PREFIX}"; \
    unzip -q /tmp/elixir.zip -d "${ELIXIR_PREFIX}"; \
    rm /tmp/elixir.zip

RUN set -eux; \
    mix local.hex --force; \
    mix local.rebar --force; \
    erl -noshell \
      -eval 'io:format("OTP ~s~n", [erlang:system_info(otp_release)]), halt().'; \
    elixir --version; \
    python --version


WORKDIR /workspace
