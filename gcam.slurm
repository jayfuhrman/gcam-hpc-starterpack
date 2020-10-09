#!/bin/bash 

#SBATCH -n 2
#SBATCH --mem-per-cpu=12000
#SBATCH --partition=standard
#SBATCH --account=gcam
#SBATCH --time=72:00:00
export OMP_NUM_THREADS=1




   srun ./mpi_wrapper.exe configuration-sets/configuration_empty_scenario_components 0

