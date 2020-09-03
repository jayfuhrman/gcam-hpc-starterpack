#!/usr/bin/bash
#
#-------------------------------------------------------------------------
# permutator.sh
#
# Shell script to generate permutations of a MiniCAM configuration file
#
# Inputs:	$1	template configuration file (XML)
#			$2 	batch runner file (XML)
#
# This script
#	1) extracts file groups and values from the batch runner file into an array
#	2) generates all possible permutation of those data
#	3) inserts these into the template and write it under a unique filename
#
# Ben Bond-Lamberty and Pralit Pratel
# January 2009
#-------------------------------------------------------------------------

EXPECTED_ARGS=2

ERROR_WRONGARGS=-1
ERROR_NOFILES=-2
ERROR_ILLEGAL_PERMNUM=-3

SCENARIO_SECTION_PATTERN=/ScenarioComponents

PERL_PARSER=batch_parser.pl

declare -a grouplist		# the file groupings read in from batch file
declare -a groupsizelist	# group sizes, used to index into filelist
declare -a filelist			# single array holding all the possible values in sequence
declare -a currentpoints
declare -a groupstartpoints
declare -a filename

do_permutations()
#	Generate permutations and write out appropriately-numbered template files
{
	i=0
	while [ $i -lt $groups ]; do		# clear permutation-tracking array
		let "currentpoints[$i] = 0"
		let "i += 1"
	done
	
	notdone=1	
	perm_number=0
    target_file_index=-1
	while [[ $notdone -eq 1 ]]; do		# main loop

{	# output redirection

		# first print head section, unmodified, of the template file
		head -n $template_head $template_file
				
		# print current permutation
        echo "<ScenarioComponents>" # open our section
		i=0
		while [ $i -lt $groups ]; do
			let "index = ${groupstartpoints[i]} + ${currentpoints[i]}"
            #echo $i
            #echo "${grouplist[$i]}"
            if [[ ${grouplist[$i]} != "policy-target-runner" ]]; then
                echo ${filelist[index]} 
            else
                #echo "NO!!!"
                let "target_file_index = ${index}"
                #echo $target_file_index
            fi
			let "i += 1"
		done

		echo "</ScenarioComponents>"	# close this section

		# now put the name of the scenario in
		echo -n "<Strings> <Value name=\"scenarioName\">"
		i=0
		while [ $i -lt $groups ]; do
			let "index = ${groupstartpoints[i]} + ${currentpoints[i]}"
			echo -n ${filename[index]}
			let "i += 1"
		done
		echo "</Value> </Strings>"

		# finally finish out the template file
		tail -n $template_tail $template_file
		
} > ${template_file_root}_${perm_number}_temp.$template_file_extension    # end of output redirect

		# ---- specific to NERSC: change outFile.csv and batch-csv-output.csv refs
	
        if [ $target_file_index -eq -1 ] || [ -z "${filelist[target_file_index]}" ]; then
            cat ${template_file_root}_${perm_number}_temp.$template_file_extension | \
            sed "s/outFile.csv/outFile_${perm_number}.csv/g" | \
            sed "s/batchout.csv/batchout_${perm_number}.csv/g"  \
                > ${template_file_root}_${perm_number}.$template_file_extension
         else
            cat ${template_file_root}_${perm_number}_temp.$template_file_extension | \
            sed "s/outFile.csv/outFile_${perm_number}.csv/g" | \
            sed "s/batchout.csv/batchout_${perm_number}.csv/g" |  \
            sed "s,Value name=\"policy-target-file\">.*</Value>,Value name=\"policy-target-file\">${filelist[target_file_index]}</Value>,g" | \
            sed "s/Value name=\"find-path\">.<\/Value>/Value name=\"find-path\">1<\/Value>/g"  \
                > ${template_file_root}_${perm_number}.$template_file_extension
         fi
		rm ${template_file_root}_${perm_number}_temp.$template_file_extension
        let "target_file_index = -1"
		
		#find next one to increment
		i=0
		while [ $i -lt $groups ]; do
			let "currentpoints[$i] += 1"
			if [[ ${currentpoints[$i]} -lt ${groupsizelist[$i]} ]]; then
				break
			else
				let "currentpoints[$i] = 0"
				let "i += 1"
			fi
		done
		
		if [ $i -lt $groups ]; then
			notdone=1
		else
			notdone=0
		fi
	let "perm_number += 1"
	done 	# while
	
}


# ----------------------------------------------------------------------
# ------------- BEGINNING OF SCRIPT ------------------------------------
# ----------------------------------------------------------------------

#---------- Preliminaries ----------

if [ $# -eq $EXPECTED_ARGS ] ; then
	echo "Permutator script $0"
else
	echo "Usage: <script name> <template config file> <batch file>"
	exit $ERROR_WRONGARGS;
fi

config_dir=`dirname $1`
if [[ -e $1 && -e $2 ]]; then
	#echo "Files exist"
    true
else
	echo "One or both of input files does not exist"
	exit $ERROR_NOFILES
fi

template_file=$1

template_file_root=`echo $template_file | cut -d . -f 1`
template_file_extension=`echo $template_file | cut -d . -f 2`

# Find spot in template file to insert our permutations
template_head=`grep -m 1 -n $SCENARIO_SECTION_PATTERN $template_file | cut -d : -f 1`

if [[ $template_head -eq 0 ]]; then
	echo "Couldn't find $SCENARIO_SECTION_PATTERN in $template_file (fatal error)"
	exit
#else
	#echo "Insert point is after line $template_head"
fi

template_lines=`grep -c $ $template_file`
#echo "Total number of lines in template file is $template_lines"
let "template_tail = $template_lines - $template_head "
	# subtract 1 because we want to exclude the /ScenarioComponents line,
	# which is printed by itself, followed by the scenario name definition
#echo "Template tail section is $template_tail lines"


#---------- Load substitutions file into array ----------

perl $PERL_PARSER $2 > tempfile

{
read groups;		# overall number of component sets
#echo "Component sets = $groups"

i=0
j=0
while [[ $i -lt $groups ]]; do
	read grouplist[$i]
#	echo ${grouplist[$i]}
	read groupsizelist[$i]
#	echo ${groupsizelist[$i]}
	let "groupstartpoints[$i] = $j"
#	echo ${groupstartpoints[$i]}
	
	k=0
	while [[ $k -lt ${groupsizelist[$i]} ]]; do
		read filename[$j]
		read filelist[$j]		
#		echo ${filelist[$j]}

		j=$(expr $j + 1)
		k=$(expr $k + 1)
	done
		i=$(expr $i + 1)
done
} < tempfile

rm tempfile

# For example:
#groups=3
#grouplist=( first second third )
#groupsizelist=( 2 3 2 )
#groupstartpoints=( 0 2 5 )
#filelist=( first1 first2 second1 second2 second3 third1 third2 )

#---------- Calculate number of permutations and confirm ----------

permutations=1
i=0
while [ $i -lt $groups ]; do
	let "permutations *= ${groupsizelist[i]}"
	let "i += 1"
done

#echo $permutations

echo "$permutations files will be generated in $config_dir"
echo -n "Write files to disk (y/n)? "
read writetodisk
if [[ $writetodisk = "y" ]]; then
	do_permutations
else
	echo "Cancelled."
fi

echo "$0 done."
exit 0 
