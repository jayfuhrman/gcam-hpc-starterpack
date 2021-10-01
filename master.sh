#!/bin/bash 

# This is the main script used for running GCAM on the Evergreen cluster
# It is adapted from the NERSC version!

#echo "To ensure most up-to-date configuration-sets directory, run copy_config.sh"
#./copy_config.sh

export COMP_ID=cff2aa
export GCAMDIR=/sfs/qumulo/qhome/${COMP_ID}/GCAM-core
export SCRATCHDIR=/sfs/lustre/bahamut/scratch/${COMP_ID}


EXPECTED_ARGS=2

RUN_SCRIPT=run_model.sh

PBS_TEMPLATEFILE=gcam_template.slurm
PBS_BATCHFILE=gcam.slurm



if [ $# -eq $EXPECTED_ARGS ] ; then
	echo "This is $0"
else
	echo "Usage: <script name> <template config file> <batch file>"
	exit 
fi

# --------------------------------------------------------------------------------------------
# 1. Copy everything over to scratch directory and work there
# --------------------------------------------------------------------------------------------


# skip sync of files (possibly would want to do this from HOME to EMSL_HOME?)
RUN_DIR_NAME=
#WORKSPACE_DIR_NAME=/sfs/qumulo/qhome/${COMP_ID}/gcam_dac_high_elec
INPUT_OPTIONS="--include=*.xml --include=Hist_to_2008_Annual.csv --exclude=.svn --exclude=*.*"

#otherwise will append
#jf-- commented out first line bc it was throwing errors
#mv -f ${GCAMDIR}/${RUN_DIR_NAME}/output/queryoutall*.csv ${GCAMDIR}/${RUN_DIR_NAME}/output/queries/
cd ${GCAMDIR}/${RUN_DIR_NAME}

# --------------------------------------------------------------------------------------------
# 2. Generate the required permutations of the base configuration file
# --------------------------------------------------------------------------------------------
        
template_path=`dirname $1`
template_root=`basename $1 | cut -f 1 -d.`
echo $template_path
echo $template_root

echo "Generate permutations (y/n)?"
read generate
if [[ $generate = 'y' ]]; then
        echo "Generating..."
        ./permutator.sh $1 $2
        if [[ $? -lt 0 ]]; then
                exit;
        fi
fi

# --------------------------------------------------------------------------------------------
# 3. Figure out how many jobs will be run and generate the gcam.pbs batch file
# --------------------------------------------------------------------------------------------

first_task=0

echo "Number of SIMULTANEOUS RUNS to run (normally same as total runs)?"
read num_tasks

let "last_task=$num_tasks - 1"

let "tasks=$last_task - $first_task + 1"

sed "s/NUM_TASKS/${num_tasks}/g" $PBS_TEMPLATEFILE \
	> $PBS_BATCHFILE

echo "
   srun ./mpi_wrapper.exe ${template_path}/${template_root} ${first_task}
"	>> $PBS_BATCHFILE

# --------------------------------------------------------------------------------------------
# 4  Go ahead and run!
# --------------------------------------------------------------------------------------------

echo "Run $tasks tasks on cluster (y/n)?"
read run

if [[ $run = 'y' ]]; then
	echo "Copying input directory to scratch..."
	rm -rf ${SCRATCHDIR}/input	 	# just in case
	cp -fR ${GCAMDIR}/input ${SCRATCHDIR}/input
    echo "Done copying input directory"

	echo "Creating empty output and error directories in scratch directory..."
    
	if [[ -d ${SCRATCHDIR/output} ]]; then
        rm -rf ${SCRATCHDIR}/output
		echo "Removed existing scratch output folder"
    fi
    mkdir ${SCRATCHDIR}/output


	echo "Copying queries directory to scratch output..."
	rm -rf ${SCRATCHDIR}/output/queries	 	# just in case
	cp -fR ${GCAMDIR}/output/queries ${SCRATCHDIR}/output/queries
    echo "Done copying queries directory"

	
	if [[ -d ${SCRATCHDIR/errors} ]]; then
        rm -rf ${SCRATCHDIR}/errors
		echo "Removed existing scratch errors folder"
    fi
    mkdir ${SCRATCHDIR}/errors


	#echo "copying addons to scratch..."
	#this is to avoid deleting addons directory when we go to build updated versions of GCAM source code, which require overwriting the gcam dir.
	#cp -fR ../gcam_addons ${SCRATCHDIR}/input/addons
	#./copy_addons.sh
	#echo "done copying addon input files to scratch"

		
	
    
    echo "Done creating scratch directories."


	job=`sbatch $PBS_BATCHFILE`
	echo "We are off and running with job $job"

fi

#./watch_pbs.sh


exit


# --------------------------------------------------------------------------------------------
# 5. Cleanup
# --------------------------------------------------------------------------------------------

# Delete the configuration files for tasks we're not running
echo "All done.  Delete generated configuration files?"
read del
if [[ $del -eq 'y' ]]; then
	t=0
	while [ $t -lt $first_task ];
	do
		echo "Removing {template_root}_${t}.xml"
		rm ${template_path}/${template_root}_${t}.xml
		let "t += 1"
	done
fi

