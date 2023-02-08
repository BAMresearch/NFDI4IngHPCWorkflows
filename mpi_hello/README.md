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

### Tests
In the HPC environment [Apptainer](https://apptainer.org) seems promising,
to be able to run containers as one would run a MPI application.
```sh
$: srun -t 00:05:00 -N $(NNODES) -n $(NPROCS) mpirun apptainer exec ./mpi_hello.sif hello.exe
```

#### Single node execution
#TODO: report results for host/bind model

#### Multiple node execution
#TODO: report results for host/bind model

## Conda environments
Besides container technology, one may also use [conda](https://docs.conda.io/en/latest/) to
create the compute environment (for local development).
With [conda-pack](https://conda.github.io/conda-pack/) *conda environments* can be archived and installed on other
systems and locations.

### Tests
To test the capabilities of `conda-pack` we use again the above hello world program `mpitest.c`.
For use in an HPC environment, the most important question is how to deal with
MPI (implementation, version) such that the environment/application is still operable.
Therefore, different variants are tested.
The specification files for the different environments can be found under `cenvs`.
The environments target the HPC system (host) available for testing purposes with the
following libraries/compilers available:

* openmpi version 4.1.2
* gcc version 12.2.0
* (optional) make version 4.3

#### Variant 1
conda environment contains same MPI implementation (openmpi, mpich) and version as host.

Steps:
1. (local linux workstation): create environment
```sh
$ mamba env create -n <env-name> -f cenvs/variant_1.yaml -p PREFIX
```
2. (local linux workstation): use `conda-pack` to create archive
```sh
$ mamba install -c conda-forge conda-pack
$ conda pack -n <env-name> -o archive.tar.gz
```
3. transfer the archive to the target machine (i.e. `scp ...`)
4. (on target machine): unpack environment
```sh
$ mkdir -p my_env
$ tar -xzf archive.tar.gz -C my_env
# Activate the environment
$ source my_env/bin/activate
# Cleanup prefixes
(my_env) $ conda-unpack
# Everything should work
# Deactivate once you are done
(my_env) $ source my_env/bin/deactivate
```
The job is then defined in `mpijob_v1.sh` and submitted via
```sh
sbatch mpijob_v1.sh
```

#### Variant 2
conda environment contains different MPI implementation than host. (negative test)
