# ==================================================================
# module list
# ------------------------------------------------------------------
# Ubuntu           16.04
# CUDA             9.2
# CuDNN            7-dev
# boost            latest   (apt)
# arrayfire        3.6.1    (git, CUDA backend)
# googletest       master   (git)
# OpenMPI          4.0.0    (bin)
# Cereal           1.2.2    (git)
# flashlight       master   (git, CUDA backend)
# ==================================================================

FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
        emacs \
        nano \
        htop \
        g++ \
        # for Cereal
        libboost-all-dev \
        gcc-multilib g++-multilib \
        # nccl: for flashlight
        libnccl2 libnccl-dev 
# ==================================================================
# arrayfire https://github.com/arrayfire/arrayfire/wiki/
# ------------------------------------------------------------------
RUN cd /tmp && git clone --recursive https://github.com/arrayfire/arrayfire.git && \
    cd arrayfire && git checkout b443e14 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DAF_BUILD_CPU=OFF -DAF_BUILD_OPENCL=OFF -DAF_BUILD_EXAMPLES=OFF && \
    make -j8 && \
    make install 
# ==================================================================
# GoogleTest https://github.com/google/googletest/
# ------------------------------------------------------------------
RUN    cd /tmp && git clone --recursive https://github.com/google/googletest && \
    cd googletest && \
    mkdir build && cd build && \
    cmake .. && \
    make -j8 && \
    make install 
# ==================================================================
# OpenMPI https://www.open-mpi.org/
# ------------------------------------------------------------------
RUN cd /tmp && wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz && \
    gunzip -c openmpi-4.0.0.tar.gz | tar xf - && \
    cd openmpi-4.0.0 && \
    ./configure --prefix=/usr/local && \
    make all install 
# ==================================================================
# Cereal http://uscilab.github.io/cereal/
# ------------------------------------------------------------------
RUN cd /tmp && git clone --recursive https://github.com/USCiLab/cereal && \
    cd cereal && git checkout v1.2.2 && \
    mkdir build && cd build && \
    cmake .. && \
    make -j8 && \
    make install 
# ==================================================================
# flashlight with GPU backend
# ------------------------------------------------------------------
#RUN mkdir /tmp/flashlight
#COPY ./* /tmp/flashlight/


RUN cd /tmp && git clone --recursive https://github.com/paiforsyth/flashlight.git 
RUN   cd /tmp/flashlight && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DFLASHLIGHT_BACKEND=CUDA -DFL_BUILD_DISTRIBUTED=OFF &&  \
    make -j8  && \
    make install
# ========================================================= =========
# config & cleanup
# ------------------------------------------------------------------
RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
