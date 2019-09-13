#!/bin/ksh

set -x

# This script is to send files to CPS
# Premium Technology Inc.
# change history:
# 6/29/2008 Initial version, mluo
# 11/11/2009 Modified for CITICA - ammend ACH file before sending. //YW77018
#
# ===========================================================
# change the following settings according to the environment
# set NDM environment
export NDMAPICFG=/opt/cdunix/ndm/cfg/cliapi/ndmapi.cfg
NDM_BIN=/opt/cdunix/ndm/bin

# set the parameters
DIR_OUTGOING=/home/cdardfuat/UAT/outCPS/CITICA
DIR_BACKUP=/home/cdardfuat/UAT/backup/outCPS/CITICA
CPS_NODE=NDMTEST
CPS_FILE="CATDLTQX.NDMFILES.CI1026AR(+1)"

# ===========================================================
export PATH=$PATH:$NDM_BIN

# call NDM sender
DIR_WORK=/home/cdardfuat/UAT/scripts/CPS/bin
LOG_FILE=$DIR_WORK/../log/PremiumToCPS_CITICA-`date +%Y%m%d-%H%M%S`.log

for donefile in `ls ${DIR_OUTGOING}/*.done` 
do
awk '{gsub("^300          02","300          22");print}' ${donefile} > ${donefile}.temp
/bin/mv -f ${donefile}.temp ${donefile}
done


$DIR_WORK/NDM-FileSender-toCPS.sh "$DIR_OUTGOING" "$DIR_BACKUP" "$CPS_NODE" "$CPS_FILE" > $LOG_FILE
# end of file

