#!/usr/bin/env python

from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import print_function

import argparse
import hpccm

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="write a container specification file")
    parser.add_argument(
        "--format",
        type=str,
        default="docker",
        choices=["docker", "singularity"],
        help="Container specification format (default: docker)",
    )
    parser.add_argument(
        "--image",
        type=str,
        default="centos:7",
        choices=["centos:7", "ubuntu:18.04"],
        help="Base container image (default: %(default)s)",
    )
    args = parser.parse_args()

    # ### Create Stage
    stage = hpccm.Stage()

    # ### Base image
    stage += hpccm.primitives.baseimage(image=args.image, _docker_env=False)

    # ### gnu compilers
    compiler = hpccm.building_blocks.gnu()
    stage += compiler

    # ### openmpi
    options = ["--with-slurm"]
    stage += hpccm.building_blocks.openmpi(
        configure_opts=options,
        cuda=False,
        infiniband=False,
        prefix="/opt/openmpi/4.1.2",
        version="4.1.2",
        toolchain=compiler.toolchain,
    )

    # ### Make the port accessible (Docker only)
    # stage += hpccm.primitives.raw(docker="EXPOSE 8888")

    # ### MPI Hello World
    stage += hpccm.primitives.copy(src="hello.c", dest="/home/hello.c")
    stage += hpccm.primitives.shell(
        commands=[
            "mpicc -std=c99 -g -O3 /home/hello.c -o /usr/local/bin/hello.exe -lm",
        ]
    )

    # ### Set container specification output format
    hpccm.config.set_container_format(args.format)

    # ### Output container specification
    print(stage)
