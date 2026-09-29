#!/usr/bin/env bash
#SBATCH --job-name=hold-node
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH --mem=512M
#SBATCH --time=00:04:00
#SBATCH --output=logs/hold-%j.out
set -euo pipefail
echo "Holding the node for 180 seconds"
srun --ntasks=1 sleep 180
