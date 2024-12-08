FROM ubuntu:22.04 AS builder

RUN apt-get update && \
    apt-get install -y \
    libcjson-dev \
    libtiff5-dev \
    build-essential \
    cmake \
    pkg-config \
    libfftw3-dev \
    libgsl-dev \
    libomp-dev \
    libpng-dev \
    wget \
    ocl-icd-opencl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/nd2tool

RUN wget https://github.com/elgw/nd2tool/archive/refs/tags/v0.1.7.tar.gz && \
    tar -xzf v0.1.7.tar.gz --strip-components=1 && \
    rm v0.1.7.tar.gz && \
    mkdir build && cd build && \
    cmake .. && \
    cmake --build . && \
    make install

WORKDIR /opt/deconwolf

RUN wget https://github.com/elgw/deconwolf/archive/refs/tags/v0.4.3.tar.gz && \
    tar -xzf v0.4.3.tar.gz --strip-components=1 && \
    rm v0.4.3.tar.gz && \
    mkdir build && cd build && \
    cmake -DOPENCL=1 .. && \
    cmake --build . && \
    make install

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    software-properties-common && \
    add-apt-repository multiverse && \
    apt-get update && \
    apt-get install -y \
    libcjson1 \
    libtiff5 \
    libfftw3-bin \
    libgsl27 \
    libomp5 \
    libpng16-16 \
    ocl-icd-libopencl1 \
    libnvidia-compute-550 \
    clinfo && \
    apt-get remove -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local
ENV LD_LIBRARY_PATH=/usr/local/lib
