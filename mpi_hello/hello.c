#include <stdio.h>
#include <stdlib.h>

// Include MPI header to declare MPI prototypes and con
#include <mpi.h>

int main (int argc, char* argv[])
{
    // Initialise the MPI library
    MPI_Init(&argc, &argv);

    // Obtain the process ID and the number of processes
    int worldrank, worldsize;
    MPI_Comm_rank(MPI_COMM_WORLD, &worldrank);
    MPI_Comm_size(MPI_COMM_WORLD, &worldsize);

    // Display the process ID and the number of processes
    printf("Hello world from rank %d of %d in communicator MPI_COMM_WORLD.\n", worldrank, worldsize);

    // Finalize the MPI library
    MPI_Finalize();
    return EXIT_SUCCESS;
}
