FROM centos:7

# GNU compiler
RUN yum install -y \
        gcc \
        gcc-c++ \
        gcc-gfortran && \
    rm -rf /var/cache/yum/*

# OpenMPI version 4.1.2
RUN yum install -y \
        automake \
        bzip2 \
        file \
        hwloc \
        make \
        numactl-devel \
        openssh-clients \
        perl \
        tar \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v4.1/downloads/openmpi-4.1.2.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-4.1.2.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-4.1.2 &&  CC=gcc CXX=g++ F77=gfortran F90=gfortran FC=gfortran ./configure --prefix=/opt/openmpi/4.1.2 --with-slurm --without-cuda --without-verbs && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-4.1.2 /var/tmp/openmpi-4.1.2.tar.bz2
ENV LD_LIBRARY_PATH=/opt/openmpi/4.1.2/lib:$LD_LIBRARY_PATH \
    PATH=/opt/openmpi/4.1.2/bin:$PATH

COPY hello.c /var/tmp/hello.c

RUN mpicc -std=c99 -g -O3 /var/tmp/hello.c -o /usr/local/bin/hello.exe -lm
