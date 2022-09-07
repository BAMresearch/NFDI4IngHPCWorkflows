# MPI Hello World
The purpose of this example is to test the parallel execution
of containers in a HPC context.

## Hello world program
The example program is `hello.c` which displays the process ID
and the number of processes.
The `Makefile` can be used to compile and run the program (executable is then
`hello.exe`)
```sh
make
make run
```
Run manually with
```sh
mpiexec -np 4 ./hello.exe
```
You should see
```sh
Hello world from rank 2 of 4 in communicator MPI_COMM_WORLD.
Hello world from rank 3 of 4 in communicator MPI_COMM_WORLD.
Hello world from rank 1 of 4 in communicator MPI_COMM_WORLD.
Hello world from rank 0 of 4 in communicator MPI_COMM_WORLD.
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

## Tests
In the HPC environment [Apptainer](https://apptainer.org) seems promising,
to be able to run containers as one would run a MPI application.
```sh
$: srun -t 00:05:00 -N $(NNODES) -n $(NPROCS) mpirun apptainer exec ./mpi_hello.sif hello.exe
```

### Single node execution
TODO

### Multiple node execution
TODO
