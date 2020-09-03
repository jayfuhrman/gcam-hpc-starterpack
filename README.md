# gcam-installation
This package automates the compilation/build process of the Global Change Analysis Model (GCAM) on UVA's High Performance Computing Cluster, as well as sets up a structure for querying data from completed model runs.  It is made publically available to streamline the process of compiling and running the model for the first time for future UVA researchers. Note that this package was created specifically for use on UVA's cluster, as other clusters may have different libraries installed and/or different protocols for submitting jobs. 



To begin, download the gcam-core zipfile from https://github.com/JGCRI/gcam-core
You will also need the hector-gcam-integration zipfile from https://github.com/JGCRI/hector/archive/gcam-integration.zip

After downloading both zipfiles and this directory, place both zip files in the top level of this directory.  

The makescript included here should automatically move into place and unpack the zipfiles during the build process, creating a separate "gcam" directory from which you will actually run the model.  

Note also that you will need to substute your computing ID in the makescript, run_model, and master shell scripts before attempting to compile/run GCAM.


