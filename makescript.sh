echo "WARNING: THIS WILL DELETE YOUR EXISTING GCAM DIRECTORY.  IF YOU DON'T NEED A COMPLETELY CLEAN INSTALL PLEASE CANCEL AND RUN rebuild_gcam.sh INSTEAD!"

#sleep 20s
module purge

module load xerces java
module load gcc/7.1.0
module load intel/20.0 intelmpi/20.0 eigen/3.4-rc1 boost




module list

GCAMDIR=/home/jgf5fz/gcam_5_4 #defines the directory that will be created with the new GCAM version.  NOTE THIS SHOULD BE DIFFERENT FROM YOUR STABLE INSTALL OTHERWISE YOU WILL DELETE IT

INSTALLDIR=/home/jgf5fz/gcam-hpc-starterpack #defines the directory from which all the dependent files to actually run GCAM are located 
HECTORDIR=${GCAMDIR}/cvs/objects/climate/source #defines where hector-gcam-integration will be installed
PACKAGE=gcam-core-master #defines zip filename from github NOTE: DO NOT INCLUDE THE .ZIP IN THE PATH AS IT WILL BE APPENDED IN THE SCRIPT WHERE NEEDED
PACKAGE_UNZIPPED=gcam-core-master

rm -rf ${GCAMDIR}
mkdir ${GCAMDIR}
cp gcam_build.setup ${GCAMDIR}
cp ${INSTALLDIR}/${PACKAGE}.zip ${GCAMDIR}
cd ${GCAMDIR}
unzip ${PACKAGE}.zip

mv ${GCAMDIR}/${PACKAGE_UNZIPPED}/* ${GCAMDIR}/.* . 
#move up all files in the directory we just unpacked up to main dir.



echo "unzipped gcam-core package"

sleep 3s


echo "copying miscelaneous files you will need to run into gcam directory"
cd ${INSTALLDIR}
cp -fR configuration-sets ${GCAMDIR}
#cp -fR addons ${GCAMDIR}/input
cp -fR libs ${GCAMDIR}






cp -fR master.sh ${GCAMDIR}
cp -fR batch_parser.pl ${GCAMDIR}
cp -fR mpi_wrapper.cpp ${GCAMDIR}
cp -fR mpi_wrapper.exe ${GCAMDIR}
cp -fR gcam_template.slurm ${GCAMDIR}
cp -fR run_model.sh ${GCAMDIR}
cp -fR permutator.sh ${GCAMDIR}
cp -fR ModelInterface.sh ${GCAMDIR}

echo "done copying misc. files"
sleep 2s


./copy_queries.sh
echo "Done copying query files."

echo "

The build process will fail unless you have separately installed gcam's simple climate model, hector. Please ensure you have downloaded the latest version of hector by following the link below and clicking hector-gcam-integration:

http://jgcri.github.io/gcam-doc/gcam-build.html#3-compiling-hector

If you have already done this, you may safely ignore this message.  This script will automatically move the downloaded .zip file from this install directory into the appropriate location in your gcam-core directory"

sleep 10s

echo "Unpacking hector"
sleep 2s

cp ${INSTALLDIR}/hector-gcam-integration.zip ${HECTORDIR}
cd ${HECTORDIR}
pwd 
sleep 5s
unzip hector-gcam-integration.zip 
rm -rf ${HECTORDIR}/hector
mv hector-gcam-integration hector
#rm -rf ${HECTORDIR}/hector/hector-gcam-integration	 	
cd ${GCAMDIR}



echo "Successfully unpacked hector. Now building GCAM"
sleep 2s

cp ${INSTALLDIR}/libs ${GCAMDIR}





#make clean #uncomment if error
source gcam_build.setup
make gcam -j 16 #comment out if error
#make gcam #uncomment if error


# uncomment if for whatever reason we want to remake the gcam data system
module load goolf/7.1.0_3.1.4 R
make

cp ${GCAMDIR}/exe/configuration_ref.xml ${GCAMDIR}/configuration-sets
cd ${GCAMDIR}/configuration-sets
mv configuration_ref.xml configuration.xml
cd ..
echo "Finished copying config file"
