#!/usr/bin/env bash
#SBATCH --job-name=mpi-hello
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=512M
#SBATCH --time=00:02:00
#SBATCH --output=logs/mpi-hello-%j.out
#SBATCH --error=logs/mpi-hello-%j.err
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
export OMP_NUM_THREADS=1
mpirun -np "$SLURM_NTASKS" ./mpi_hello
