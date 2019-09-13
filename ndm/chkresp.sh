#!/bin/bash
#
# Script to check response files sent. The tool will either display all the files along with the process ID
# or search the files matched the return file IDs provided.
#
# Yang Wang, 11/12/09
#

NO_ARGS=0
E_OPTERROR=65

Usage() {
	echo ""
	echo "Usage:"
	echo "chkresp [-r] env"
	echo "        env  = SIT, UAT, PRD, PRE"
	echo "        -r   = search based on return file ID"
	echo "        -n d = days to search"
	echo ""
} 

if [[ $# < 1 ]]; then
		Usage
        exit $E_OPTERROR
fi

# Setting the default values
opt=""
days="2"

while getopts "rn:" Option
do
	case $Option in
		r ) opt="r";;
		n ) days=$OPTARG;;
		* ) ;;
	esac
done

shift $(($OPTIND - 1))

ofile=yw77018_$$

echo ""
echo Now I am checking the response files sent so far - in the last 24 hours.
echo Being patient because it will take a while...
chkit2.sh -s -n ${days} $1 outGXS > /tmp/${ofile}.res

echo ""
echo Now I am checking the logs...it will take a while too.
echo So, be patient. Thanks.
cdlog.sh -n ${days} $1 GXS > /tmp/${ofile}.log

fid=""

if [[ ${opt} == "r" ]]; then
	echo ""
	echo "And enter the return file IDs, separated by space. Two ENTER to finish."
	while :
	do
		read word
		if [[ ${word} == "" ]]; then
			break
		fi
		fid=${fid}" "${word}
		word=""
	done
	echo "Now I will check the response files one by one..."
fi

error="N"
total=0
nerror=0
ndone=0
for fn in ${fid}; do
   let total=total+1
   printf "Return File ID - "
   printf "${fn}"
   printf "............."

   grep -i ${fn} /tmp/${ofile}.res > /dev/null
   r=$?
   grep -i ${fn} /tmp/${ofile}.log > /dev/null

   let "r=$r+$?"
   
   if [[ ${r} != 0 ]]; then
		let nerror=nerror+1
        error="Y"
		printf "Nope"
   else
	    let ndone=ndone+1
        printf "OK  "
		printf '\n'

		str="\\."${fn}"[a-zA-Z0-9]*\\."
		nawk '/'${str}'/ { print "  ", $1, $2; getline; print "      ", $1; getline; print "      ", $1; getline; print "      ", $1 }' /tmp/${ofile}.log
   fi
done

if [[ ${opt} == "r" ]]; then
	printf '\n\n'
	echo "Done. Total ${total} file IDs checked, where ${ndone} with files sent successfully and ${nerror} without files sent."
	echo ""
else
	nawk '/^File/ { print "  ", $1, $2; getline; print "      ", $1; getline; print "      ", $1; getline; print "      ", $1 }' /tmp/${ofile}.log
fi

rm /tmp/${ofile}.*
