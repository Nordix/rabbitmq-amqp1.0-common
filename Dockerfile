FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG OTP_VERSION

ENV ERLANG_PREFIX=/opt/erlang
ENV PATH=/opt/erlang/bin:${PATH}
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    ca-certificates \
    curl \
    git \
    libncurses5-dev \
    libssl-dev \
    m4 \
    make \
    perl \
    python3 \
    python-is-python3 \
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
    ./configure --prefix="${ERLANG_PREFIX}" \
      --without-wx \
      --without-odbc \
      --without-javac \
      --without-debugger \
      --without-observer \
      --without-et; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/otp-src /tmp/otp.tar.gz

RUN erl -noshell \
      -eval 'io:format("OTP ~s~n", [erlang:system_info(otp_release)]), halt().'

WORKDIR /workspace
