FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential cmake git clang ninja-build \
    llvm-18 llvm-18-dev llvm-18-tools \
    libffi-dev libxml2-dev libedit-dev zlib1g-dev libcurl4-openssl-dev libzstd-dev \
    llvm-18-runtime llvm-18-tools


ENV LLVM_DIR=/usr/lib/llvm-18/cmake

WORKDIR /workspace

COPY . /workspace

RUN mkdir -p build && cd build && cmake -DLLVM_DIR=$LLVM_DIR .. && make
