#!/bin/bash
#SBATCH --job-name=yourjobname  #(specify your jobname)
#SBATCH --output=/shared/slurm/pathtoyourfolder/output_%j.log #Specify your path
#SBATCH --partition=compute
#SBATCH --ntasks=1

source /etc/profile.d/modules.sh
module purge                     # to clear previously loaded modules
module use /shared/apps/modules
module load pytorch/2.7.0       # or tensorflow/2.19.0

# Your script below

echo "Running on node: $(hostname)"

python yourfilename.py
