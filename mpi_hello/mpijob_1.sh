#!/bin/bash

#SBATCH --job-name=mpitest_conda_v1
#SBATCH --time=00:01:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=3

#SBATCH --mail-type=ALL
#SBATCH --mail-user=philipp.diercks@bam.de

### Output files

#SBATCH --error=/home/%u/mpitest_conda/jobs/job.%J.err
#SBATCH --output=/home/%u/mpitest_conda/jobs/job.%J.out

module purge

source ./env_v1/bin/activate
conda-unpack

echo "+ which mpicc"
which mpicc
echo "+ which mpirun"
which mpirun

mpicc -o mpitest.exe mpitest.c
mpirun ./mpitest.exe
# clean up
rm ./mpitest.exe
