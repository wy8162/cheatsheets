#!/bin/ksh 

# This script is to rename a file to a name with appended ".done"
# Premium Technology Inc.
# change history:
# 6/29/2008 Initial version, mluo 
#
# Modified to handle duplicate files to avoid overwriting.
# 11/2/09

# Usage:
# ./rename_file.sh filename
#   where 
#     filename           is the original file name
#

WORK_DIR=/home/cdardfuat/SIT/inGXS

v=$1
base=""
ext=`echo $v | awk -F. '{if(NF>1){print $NF;}else{print ""}}'`
len=${#v}
lenext=${#ext}
if [[ $lenext = 0 ]]; then
	base=$v.
	ext="done"
else
	base=${v%%$ext}
	ext=$ext".done"
fi

ts=`date +%y%m%d%H%M%S`

SRC_FILE=$WORK_DIR/$v
DST_FILE=$WORK_DIR/$base$ext
DST_TS_FILE=$WORK_DIR/$base$ts.$ext

if [ -e ${SRC_FILE} ]; then
  # source file exists
  if [ -e ${DST_FILE} ]; then
	# There exists a file of the same name
	mv ${SRC_FILE} ${DST_TS_FILE}
  else
	# Rename the file to *.done
	mv ${SRC_FILE} ${DST_FILE}
  fi
else
  exit 1
fi

# end of file

