#!/bin/bash 

#SBATCH -n NUM_TASKS
#SBATCH --mem-per-cpu=12000
#SBATCH --partition=standard
#SBATCH --account=gcam
#SBATCH --time=10:00:00
export OMP_NUM_THREADS=1



