#!/bin/bash
#
# Script to process NDM log files. This script will find the log files and retrieve the information needed.
#
# Yang Wang, 11/16/09
#
NO_ARGS=0
E_OPTERROR=65

Usage() {
		echo ""
        echo "Usage:"
        echo "chkndm [-nlv] env"
        echo "      env = SIT, UAT, PRD, PRE"
		echo "      -l  = long display"
		echo "      -v  = verbose display (default)"
		echo "      -n d= numbers in 24 hours"
		echo ""
}

if [[ $# < 1 ]]; then
		Usage
        exit $E_OPTERROR
fi

# Setting the default values
opt=""
verbose=""
days="1"

while getopts "lvn:" Option
do
	case $Option in
		l ) opt="l";;
		v ) verbose="v";;
		n ) days=$OPTARG;;
		* ) ;;
	esac
done

shift $(($OPTIND - 1))

LOGDIR="/opt/cdunix/work/ardfasmdu11"
case $1 in
	"SIT" ) ;;
	"UAT" ) ;;
	"PRD" ) LOGDIR="/opt/cdunix/work/ardfprod";;
	"PRE" ) ;;
	*     )
		Usage
		exit $E_OPTERROR
		;;
esac

fn=/tmp/yw77018_awk.$$

if [[ $opt == "l" ]]; then
cat > ${fn} << 'EOF' 
BEGIN {
  FS="|"
  cnt=0
  option="l"
}
EOF
else
cat > ${fn} << 'EOF' 
BEGIN {
  FS="|"
  cnt=0
  option="m"
}
EOF
fi

cat >> ${fn} << 'EOF' 
/MSST=Copy step successful/ && !/zeroByteSignal.txt/ { # Found the message for successful copy session
	INOUT="SND: "
	STAR=""
	PNUM=""
	SUBM=""
	PNOD=""
	SNOD=""
	SFIL=""
	DFIL=""

	# 1-Start 3-PNUM 9-SUBM user ID 28-PNOD 29-SNOD 48-SFIL 60-DFIL
	for (i=1; i<= NF; i++) {
		if (substr($i, 1, 4) == "STAR") STAR=$i
		else if (substr($i, 1, 4) == "PNUM") PNUM=$i
		else if (substr($i, 1, 4) == "SUBM") SUBM=$i
		else if (substr($i, 1, 4) == "PNOD") PNOD=$i
		else if (substr($i, 1, 4) == "SNOD") SNOD=$i
		else if (substr($i, 1, 4) == "SFIL") SFIL=$i
		else if (substr($i, 1, 4) == "DFIL") DFIL=$i
	}
	
	if (SNOD ~ /ardf.*/) INOUT="RCV: "
	sub("\.wait$", "", SFIL)
	sub("/home/cdardf[a-zA-Z0-9]*/", "", SFIL)

	if (option == "l") {
		print INOUT, STAR, PNUM, SUBM, PNOD, SNOD, SFIL, DFIL
	} else {
		if (INOUT == "SND: ") print INOUT STAR, PNUM, SFIL
		else print INOUT STAR, PNUM, DFIL
	}
	cnt=cnt+1
}
END {
  if (option == "l") print "Total ", cnt, "file(s) sent/received."
}
EOF

for f in $(find ${LOGDIR} -name "S*" -mtime -${days} -type f -print)
do
	if [[ ${verbose} == "v" ]]; then
		echo $f
	fi
	nawk -f ${fn} $f
done

rm ${fn}
