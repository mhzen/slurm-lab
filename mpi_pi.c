#include <mpi.h>
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    int rank, size, valid = 1;
    long long n = 100000000;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0 && argc > 1) {
        char *end;
        errno = 0;
        n = strtoll(argv[1], &end, 10);
        valid = !errno && end != argv[1] && *end == '\0'
                && n > 0 && n <= 1000000000LL;
    }
    MPI_Bcast(&valid, 1, MPI_INT, 0, MPI_COMM_WORLD);
    if (!valid) {
        if (rank == 0)
            fprintf(stderr, "Use 1 to 1000000000 intervals\n");
        MPI_Finalize();
        return 2;
    }
    MPI_Bcast(&n, 1, MPI_LONG_LONG_INT, 0, MPI_COMM_WORLD);
    double h = 1.0 / (double)n;
    double local_sum = 0.0, pi = 0.0, max_seconds = 0.0;
    MPI_Barrier(MPI_COMM_WORLD);
    double start = MPI_Wtime();
    for (long long i = rank; i < n; i += size) {
        double x = ((double)i + 0.5) * h;
        local_sum += 4.0 / (1.0 + x * x);
    }
    local_sum *= h;
    MPI_Reduce(&local_sum, &pi, 1, MPI_DOUBLE, MPI_SUM,
               0, MPI_COMM_WORLD);
    double seconds = MPI_Wtime() - start;
    MPI_Reduce(&seconds, &max_seconds, 1, MPI_DOUBLE, MPI_MAX,
               0, MPI_COMM_WORLD);
    if (rank == 0) {
        printf("ranks,intervals,pi,abs_error,seconds\n");
        printf("%d,%lld,%.15f,%.3e,%.6f\n", size, n, pi,
               fabs(pi - acos(-1.0)), max_seconds);
    }
    MPI_Finalize();
    return 0;
}
