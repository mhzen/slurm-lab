# Slurm and MPI virtual machine laboratory

Read `Slurm_MPI_VM_Tutorial.tex` for the complete English tutorial. Upload
that file alone to a blank Overleaf project, set it as the main document
(or rename it to `main.tex`), choose pdfLaTeX, and compile. It needs no
external images, bibliography files, shell escape, or code files to compile.

The code targets a fresh Ubuntu Server 24.04 LTS VM with at least 2 vCPUs
and 4 GiB RAM. The VM is the controller and compute node. This is a
teaching configuration without an accounting database or cgroup resource
containment. It does not demonstrate performance across physical nodes.

## Working directory

Extract the archive into your home directory so that the working directory
is `~/slurm-lab`. Run commands inside the Ubuntu guest. Install and configure
the software by following the tutorial before submitting jobs.

## Files

- `configure_single_vm.sh`: creates the one-node configuration after package
  installation. Run once with sudo. It refuses to overwrite an existing
  `/etc/slurm/slurm.conf`.
- `mpi_hello.c`: rank identities and a reduction verifying the MPI world.
- `mpi_pi.c`: parallel numerical integration with CSV results.
- `jobs/hello.sbatch`: first batch job.
- `jobs/hold_node.sbatch`: exclusive allocation for the queuing exercise.
- `jobs/mpi_hello.sbatch`: MPI hello job.
- `jobs/mpi_pi.sbatch`: numerical integration job.
- `jobs/pi_array.sbatch`: four independent parameter cases.
- `Makefile`: compile both C programs with `make`; remove binaries with
  `make clean`.
- `run_scaling.sh`: sequential benchmark submissions, three repeats each
  for supported counts among 1, 2, and 4 ranks.
- `summarize_scaling.py`: calculate median runtime, speedup, and efficiency
  from measured CSV files only.

## After setup

As your regular user, not root:

```bash
cd "$HOME/slurm-lab"
mkdir -p logs results
make
sbatch --wait jobs/mpi_hello.sbatch
sbatch --wait jobs/mpi_pi.sbatch 100000000
bash run_scaling.sh 100000000
```

Start with the tutorial's installation acceptance checks before running
the experiments. Job IDs, timings, and queue reasons vary between runs.
Do not submit benchmark jobs while an unused interactive allocation holds
the VM. For the optional scaling helper, inspect its newly created
`results/scaling-.../summary.csv`; existing experiments are retained.

The complete Slurm installation has not been boot-tested in a hypervisor
as part of preparing these files. Use the tutorial's checkpoints to verify
the services, node, job state, and MPI communicator on your own VM.
