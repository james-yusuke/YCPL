FROM ubuntu:24.04

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -o Acquire::Retries=3 update \
    && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        clang \
        clangd \
        cmake \
        gdb \
        git \
        less \
        libcurl4-openssl-dev \
        libedit-dev \
        libffi-dev \
        libxml2-dev \
        libzstd-dev \
        lld \
        nodejs \
        llvm-18 \
        llvm-18-dev \
        llvm-18-runtime \
        llvm-18-tools \
        ninja-build \
        npm \
        openssh-client \
        pkg-config \
        python3 \
        sudo \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN if id -u "${USERNAME}" >/dev/null 2>&1; then \
        usermod -s /bin/bash "${USERNAME}"; \
    else \
        if ! getent group "${USER_GID}" >/dev/null; then \
            groupadd --gid "${USER_GID}" "${USERNAME}"; \
        fi; \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}"; \
    fi \
    && usermod -aG sudo "${USERNAME}" \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

RUN for tool in llc opt llvm-as llvm-dis llvm-config; do \
        if [ -x "/usr/bin/${tool}-18" ]; then \
            ln -sf "/usr/bin/${tool}-18" "/usr/local/bin/${tool}"; \
        fi; \
    done

ENV LLVM_DIR=/usr/lib/llvm-18/cmake
ENV CC=clang
ENV CXX=clang++

WORKDIR /workspace/YCPL
