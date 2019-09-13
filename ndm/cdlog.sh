#!/bin/bash
#
# Script to NDM log files for files sent and process numbers, etc.
#
# Yang Wang, 11/12/09
#

NO_ARGS=0
E_OPTERROR=65

Usage() {
		echo ""
        echo "Usage:"
        echo "cdlog [-n] env type"
        echo "      env  = SIT, UAT, PRD, PRE"
        echo "      type = GXS, CPS"
		echo "      -n d = numbers in 24 hours. Default=1"
		echo ""
}

if [[ $# < 2 ]]; then
		Usage
        exit $E_OPTERROR
fi

# Setting the default values
days="1"

while getopts "n:" Option
do
	case $Option in
		n ) days=$OPTARG;;
		* ) ;;
	esac
done

shift $(($OPTIND - 1))

t=$2
case $2 in
	"GXS" ) ;;
	"CPS" ) ;;
	*     )
		Usage
        exit 0
			;;
esac

en=$1
case $1 in
	"SIT" ) en=UAT;;
	"UAT" ) ;;
	"PRD" ) ;;
	"PRE" ) en=UAT;;
	*     )
		Usage
        exit 0
			;;
esac

venv=`echo ${en} | tr '[:upper:]' '[:lower:]'`

LOG_DIR=/home/cdardf${venv}/$1/scripts/${t}/log
# ts=`date +%Y%m%d-`

echo "Checking ${LOG_DIR} files log in the last ${days} day(s)/24-hours......"
# logfiles=`find ${LOG_DIR} -size +198c -name "PremiumToGXS-${ts}*" -type f -print`
logfiles=`find ${LOG_DIR} -size +198c -mtime -${days} -type f -print`

len=${#logfiles}
if [[ len > 0 ]]; then
   for i in ${logfiles}
   do
		nlog.sh $i
   done
fi
