CC = mpicc
CFLAGS = -O2 -Wall -Wextra -std=c11

.PHONY: all clean
all: mpi_hello mpi_pi

mpi_hello: mpi_hello.c
	$(CC) $(CFLAGS) $< -o $@

mpi_pi: mpi_pi.c
	$(CC) $(CFLAGS) $< -lm -o $@

clean:
	rm -f mpi_hello mpi_pi
