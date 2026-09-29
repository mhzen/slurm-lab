#!/usr/bin/env bash
#SBATCH --job-name=mpi-pi
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=512M
#SBATCH --time=00:05:00
#SBATCH --output=logs/pi-%j.csv
#SBATCH --error=logs/pi-%j.err
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
export OMP_NUM_THREADS=1
echo "Job=$SLURM_JOB_ID nodes=$SLURM_JOB_NODELIST" >&2
mpirun -np "$SLURM_NTASKS" ./mpi_pi "${1:-100000000}"
