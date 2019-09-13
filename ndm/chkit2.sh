#!/bin/bash
#
# Script to retrieve EDI files sent by NDM and the related Process Numbers.
#
# Yang Wang, 11/12/09
#

NO_ARGS=0
E_OPTERROR=65

Usage() {
		echo ""
        echo "Usage:"
        echo "chkit2 [-nmls] env dir"
        echo "      env = SIT, UAT, PRD, PRE"
        echo "      dir = inCPS, inGXS, outCPS, outGXS"
		echo "      -m  = summary display (default)"
		echo "      -l  = long display"
		echo "      -s  = short display"
		echo "      -n d= numbers in 24 hours"
		echo ""
}

if [[ $# < 2 ]]; then
		Usage
        exit $E_OPTERROR
fi

# Setting the default values
p="m"
days="1"

while getopts "mlsn:" Option
do
	case $Option in
		m ) p="m";;
			# echo "Scenario #1: option -m [OPTIND=${OPTIND}]";;
		l ) p="l";;
			# echo "Scenario #2: option -l [OPTIND=${OPTIND}]";;
		s ) p="s";;
			# echo "Scenario #3: option -s [OPTIND=${OPTIND}]";;
		n ) days=$OPTARG;;
			# echo "Scenario #4: option -n with argument \"$OPTARG\" [OPTIND=${OPTIND}]";;
		* ) ;;
			# echo "Unimplemented option chosen.";;
	esac
done

shift $(($OPTIND - 1))

en=$1
case $1 in
	"SIT" ) en=UAT;;
	"UAT" ) ;;
	"PRD" ) ;;
	"PRE" ) en=UAT;;
	*     )
        echo "chkit env dir [-option]"
        echo "      env = SIT, UAT, PRD, PRE"
        echo "      dir = inCPS, inGXS, outCPS, outGXS"
		echo "      option = -l, -s"
        exit 0
			;;
esac

msg=""
case $2 in
	"inCPS"  ) msg="received";;
	"inGXS"  ) msg="received";;
	"outCPS" ) msg="sent";;
	"outGXS" ) msg="sent";;
	*        )
        echo "chkit env dir [-option]"
        echo "      env = SIT, UAT, PRD, PRE"
        echo "      dir = inCPS, inGXS, outCPS, outGXS"
		echo "      option = -l, -s"
        exit 0
			;;
esac

venv=`echo ${en} | tr '[:upper:]' '[:lower:]'`

PENDING_DIR=/home/cdardf${venv}/$1/$2
SENT_DIR=/home/cdardf${venv}/$1/backup/$2

echo "Checking ${PENDING_DIR} ......"
pendingfiles=`find ${PENDING_DIR} -mtime -${days} -type f -print`
# npending=`echo ${pendingfiles} | awk '{print NF}'`

cnt=0
len=${#pendingfiles}
if [[ len > 0 ]]; then
   for i in ${pendingfiles}
   do
	   let "cnt+=1"
	   case ${p} in
					"l" ) ls -l $i;;
					"s" )
						echo "   " `ls -lrte $i | awk '{ print $6, $7, $8}'`  " "  ${i##${SENT_DIR}}
						;;
					"m" ) ;;
					*   ) ;;
	   esac
   done
fi
echo ==== There is ${cnt} files pending to be $msg
echo ""

echo "Checking ${SENT_DIR} ......"
sentfiles=`find ${SENT_DIR} -mtime -${days} -type f -print`
# nsent=`echo ${sentfiles} | awk '{print NF}'`

cnt=0
len=${#sentfiles}
if [[ len > 0 ]]; then
   for i in ${sentfiles}
   do
       let "cnt+=1"
	   case ${p} in
					"l" ) ls -l $i;;
					"s" )
						echo "   " `ls -lrte $i | awk '{ print $6, $7, $8}'`  " "  ${i##${SENT_DIR}}
						;;
					"m" ) ;;
					*   ) ;;
	   esac
   done
fi
echo "---- There are ${cnt} files $msg since last ${days} day(s)/24-hours."
echo ""
