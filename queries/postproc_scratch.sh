#this script may be used to run queries outside of the run_model.sh script on already-completed parallel model runs without using additional compute-node time.  After creating the appropriate xml files using the batch_query_generator python script, this script copies them to the appropriate locations in scratch and then cycles through the exe_n directories specified to run the queries and generate the csv queryout files.  

module load java


TARGETFILE=xmldb_batch_ag_commodity_prices_regionalized.xml
QUERYFILE=query_ag_commodity_prices_regionalized.xml

SCRATCHDIR=/scratch/jgf5fz/DAC_modeling_paper_NCC_submission/solution
HOMEDIR=/home/jgf5fz/gcam_5_3

mkdir ${SCRATCHDIR}/output
mkdir ${SCRATCHDIR}/output/queries



cp ${HOMEDIR}/output/queries/$QUERYFILE ${SCRATCHDIR}/output/queries
echo "copied query file $QUERYFILE to scratch dir"
echo "starting loop. target file = $TARGETFILE"
#for i in {0..13} #specify the exe_n range you wish to run queries on, here
for i in $(seq 5 2 13)
do
	(
	cp $HOMEDIR/exe/$TARGETFILE ${SCRATCHDIR}/exe_$i
	echo "copied target to scratchdir"
	cd ${SCRATCHDIR}/exe_$i || continue
	echo "entered exe_$i"
	java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$i/$TARGETFILE
	cd ${SCRATCHDIR}
	echo "exited exe_$i"
	#pwd
	)
done

