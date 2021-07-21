#!/bin/bash 
#SBATCH -N 1
#SBATCH --ntasks-per-node 6
#SBATCH --partition=standard
#SBATCH --account=gcam
#SBATCH --time=10:00:00

module load xerces java
module load intel/20.0 intelmpi eigen/3.4-rc1 boost
module list

export OMP_NUM_THREADS=1
export LD_LIBRARY_PATH=$EBROOTINTELMPI/intel64/lib/release:${TBBROOT}/lib/intel64/gcc4.8:$LD_LIBRARY_PATH
srun ./mpi_wrapper.exe configuration-sets/configuration_usa 0
