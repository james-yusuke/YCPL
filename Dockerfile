FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential cmake curl git gnupg ninja-build wget \
    libffi-dev libxml2-dev libedit-dev zlib1g-dev libcurl4-openssl-dev libzstd-dev \
    python3 nodejs npm

ENV LLVM_DIR=/usr/lib/llvm-22/cmake

WORKDIR /workspace

COPY . /workspace

RUN scripts/setup-llvm.sh 22

RUN mkdir -p build && cd build && cmake -DLLVM_DIR=$LLVM_DIR .. && make
