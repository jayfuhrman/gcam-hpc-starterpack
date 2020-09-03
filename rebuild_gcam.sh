module purge

module load gcc
module load intel
module load intelmpi
module load boost
module load xerces
module load java

make clean #uncomment if error
source gcam_build.setup
make gcam -j 8
