#!/usr/bin/env bash
# Run as the regular student user, outside an existing allocation.
set -euo pipefail
cd "$(dirname "$0")"
if [[ -n "${SLURM_JOB_ID:-}" ]]; then
    echo "Exit the current allocation before running this script." >&2
    exit 1
fi
lab_cpus=$(sinfo -N -h -p debug -o '%c' | head -n 1)
if [[ ! "$lab_cpus" =~ ^[0-9]+$ ]]; then
    echo "Cannot read the node CPU count from Slurm." >&2
    exit 1
fi
lab_n=${1:-100000000}
lab_run="$(date +%Y%m%d-%H%M%S)-$$"
lab_results="results/scaling-$lab_run"
mkdir -p logs "$lab_results"
printf 'ranks,repeat,job_id\n' > "$lab_results/jobs.csv"
for lab_ranks in 1 2 4; do
    (( lab_ranks <= lab_cpus )) || continue
    for lab_rep in 1 2 3; do
        lab_id=$(sbatch --wait --parsable --exclusive \
            --ntasks="$lab_ranks" jobs/mpi_pi.sbatch "$lab_n")
        lab_id=${lab_id%%;*}
        cp "logs/pi-$lab_id.csv" \
            "$lab_results/p${lab_ranks}-r${lab_rep}.csv"
        printf '%s,%s,%s\n' "$lab_ranks" "$lab_rep" "$lab_id" \
            >> "$lab_results/jobs.csv"
    done
done
python3 summarize_scaling.py "$lab_results"
echo "Results: $lab_results"
