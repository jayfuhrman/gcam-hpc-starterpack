module purge

module load gcc/7.1.0
module load intel/18.0
module load intelmpi/18.0
module load boost
module load xerces
module load java

make clean #uncomment if error
source gcam_build.setup
make gcam -j 8
