# MPI Hello World
The purpose of this example is to test the parallel execution
of containers in a HPC context.

## Hello world program
The example program is `mpitest.c`, a simple hello world program,
which is taken from the [apptainer documentation](https://apptainer.org/docs/user/1.1/mpi.html#).

The `Makefile` can be used to compile and run the program (executable is then
`mpitest.exe`)
```sh
make
make run
```
Run manually with
```sh
mpiexec -np 4 ./mpitest.exe
```
You should see
```sh
Hello, I am rank 1/4
Hello, I am rank 0/4
Hello, I am rank 2/4
Hello, I am rank 3/4
```

## Container
[HPC-container-maker](https://github.com/NVIDIA/hpc-container-maker) is used to
generate the container specification file. The recipe `container_recipe.py`
defines what should be installed and you can choose either *docker* or *singularity/apptainer*
format. 
For example run
```sh
./container_recipe.py --format docker > Dockerfile
```
to generate a specification file in docker format. Then build the container the usual way.
```bash
docker build -t name:tag -f Dockerfile PATH
docker tag name:tag username/name:tag
docker push username/name:tag
```
Note that the compilation of the hello world program is also included
in the build of the container. After successfully building the image
the program can be run with
```sh
docker run -it name:tag
(dockerroot)$: mpiexec --allow-run-as-root -np 4 /usr/local/bin/hello.exe
```
The option `--allow-run-as-root` seems to be necessary with docker.
I haven't tested with podman yet (22.03.2022, 14:46).

#TODO: 1. use apptainer definition files (host/bind model)
#TODO: 2. if 1. works, use hpccm to generate definition files more easily

## Tests
In the HPC environment [Apptainer](https://apptainer.org) seems promising,
to be able to run containers as one would run a MPI application.
```sh
$: srun -t 00:05:00 -N $(NNODES) -n $(NPROCS) mpirun apptainer exec ./mpi_hello.sif hello.exe
```

### Single node execution
#TODO: report results for host/bind model

### Multiple node execution
#TODO: report results for host/bind model
