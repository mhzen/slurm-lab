#!/usr/bin/env bash
#SBATCH --job-name=hello
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:02:00
#SBATCH --output=logs/hello-%j.out
#SBATCH --error=logs/hello-%j.err
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
echo "Job: $SLURM_JOB_ID"
echo "Nodes: $SLURM_JOB_NODELIST"
echo "Working directory: $PWD"
date -Is
srun --ntasks=1 hostname
srun --ntasks=1 sleep 15
date -Is
