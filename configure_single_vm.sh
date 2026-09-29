#!/usr/bin/env bash
# Run with sudo, once, after installing the Ubuntu packages.
set -euo pipefail
if (( EUID != 0 )); then
    echo "Run: sudo bash configure_single_vm.sh" >&2
    exit 1
fi
if [[ -e /etc/slurm/slurm.conf ]]; then
    echo "Existing slurm.conf found; leaving it unchanged." >&2
    exit 1
fi
lab_node=$(hostname -s)
lab_detected=$(/usr/sbin/slurmd -C | awk '/^NodeName=/{print; exit}')
if [[ ! "$lab_detected" =~ RealMemory=([0-9]+) ]]; then
    echo "Cannot detect node memory." >&2
    exit 1
fi
lab_memory=$(( BASH_REMATCH[1] * 80 / 100 ))
if (( lab_memory < 1536 )); then
    echo "Assign at least 4 GiB RAM to the VM, then retry." >&2
    exit 1
fi
lab_node_line=$(printf '%s\n' "$lab_detected" |
    sed -E "s/RealMemory=[0-9]+/RealMemory=${lab_memory}/")
install -d -m 0755 /etc/slurm
install -d -o slurm -g slurm -m 0755 /var/spool/slurmctld
install -d -o root -g root -m 0755 /var/spool/slurmd
install -d -o slurm -g slurm -m 0755 /var/log/slurm

cat > /etc/slurm/slurm.conf <<EOF
ClusterName=laptoplab
SlurmctldHost=${lab_node}(127.0.0.1)
SlurmUser=slurm
SlurmdUser=root
AuthType=auth/munge
CredType=cred/munge
StateSaveLocation=/var/spool/slurmctld
SlurmdSpoolDir=/var/spool/slurmd
SlurmctldPidFile=/run/slurmctld.pid
SlurmdPidFile=/run/slurmd.pid
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_CPU_Memory
TaskPlugin=task/affinity
ProctrackType=proctrack/pgid
ReturnToService=1
AccountingStorageType=accounting_storage/none
JobAcctGatherType=jobacct_gather/linux
JobCompType=jobcomp/filetxt
JobCompLoc=/var/log/slurm/jobcomp.log
MinJobAge=86400
DefMemPerCPU=256
${lab_node_line} NodeAddr=127.0.0.1 State=UNKNOWN
PartitionName=debug Nodes=${lab_node} Default=YES MaxTime=01:00:00 State=UP OverSubscribe=NO
EOF
chmod 0644 /etc/slurm/slurm.conf
echo "Created /etc/slurm/slurm.conf for ${lab_node}."
echo "Read the file before starting the Slurm services."
