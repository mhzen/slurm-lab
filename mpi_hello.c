#include <mpi.h>
#include <stdio.h>

int main(int argc, char **argv) {
    int rank, size, length, rank_sum;
    char node[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Get_processor_name(node, &length);
    printf("Hello from rank %d of %d on %s\n", rank, size, node);
    MPI_Reduce(&rank, &rank_sum, 1, MPI_INT, MPI_SUM,
               0, MPI_COMM_WORLD);
    if (rank == 0) {
        printf("CHECK ranks=%d sum=%d expected=%d\n",
               size, rank_sum, size * (size - 1) / 2);
    }
    MPI_Finalize();
    return 0;
}
