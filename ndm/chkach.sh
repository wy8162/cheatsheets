#!/bin/bash
#
# Script to check ACH files sent.
#
# Yang Wang, 11/12/09
#

Usage() {
	echo "Usage:"
	echo "chkach env"
	echo "      env  = SIT, UAT, PRD, PRE"
} 

echo

if [[ $# < 1 ]]; then
		Usage
        exit 0
fi

ofile=yw77018_ach_chk_283

trap "/bin/rm -f $ofile.*" 0 1 15  # Zap temporary files

echo ""
echo Now I am checking the ACH files sent so far - in the last 24 hours.
echo Being patient because it will take a while...
chkit2.sh -s -n 2 $1 outCPS > /tmp/${ofile}.ach

echo ""
echo Now I am checking the logs...it will take a while too.
echo So, be patient. Thanks.
chkndm.sh -n 2 $1 > /tmp/${ofile}.log

echo ""
echo "Now run the SQL to get a list of the ACH files"
echo "And enter the ACH file names (starting with ACH...) you got from the SQL query. Two ENTER to finish."

filenames=""
while :
do
	read word
	if [[ ${word} == "" ]]; then
		break
	fi
	filenames=${filenames}" "${word}
	word=""
done

echo ""
echo Now I will check these files one by one...
error="N"

total=0
nerror=0
ndone=0
for fn in ${filenames}; do
   if [[ ${fn} =~ "[aA][cC][hH].*" ]]; then
	   let total=total+1
	   printf '\nChecking...'
	   printf "${fn}"
	   printf "........."
	   grep -i ${fn} /tmp/${ofile}.ach > /dev/null
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
			x=`grep -i ${fn} /tmp/${ofile}.log`
			pnum=`echo $x | awk '{ print $1, $2, $3, $4 }'`
			printf "%s %s %s $s" ${pnum}
	   fi
	fi
done

printf '\n\n'

echo "Done. Total ${total} files, ${ndone} sent successfully and ${nerror} need to be investigated."
echo ""

rm /tmp/${ofile}.ach
rm /tmp/${ofile}.log
