#!/usr/bin/env bash
#SBATCH --job-name=pi-array
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:05:00
#SBATCH --array=0-3%2
#SBATCH --output=logs/array-%A_%a.csv
#SBATCH --error=logs/array-%A_%a.err
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
export OMP_NUM_THREADS=1
sizes=(1000000 10000000 50000000 100000000)
n=${sizes[$SLURM_ARRAY_TASK_ID]}
mpirun -np "$SLURM_NTASKS" ./mpi_pi "$n"
