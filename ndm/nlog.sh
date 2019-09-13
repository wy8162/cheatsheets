#!/bin/sh
#
# Script to retrieve EDI files sent by NDM and the related Process Numbers.
# The second sed is to eliminate blank lines, junk lines and duplicate lines.
#
# Yang Wang, 8/7/09
#
case $# in
	"1" )   break
		;;

	* )
		echo "Usage: nlog.sh ndmlog_file"; exit
		;;
esac
sed -e '
# Delete all lines "*......*"
/\*.*\*/d
# Delete all empty lines
/^$/d
/./!d
# Delete BOTH leading and trailing whitespace from each line
s/^[ ]*//;s/[ ]*$//
# Delete all control characters
s/[[:cntrl:]]//g
# Delete un-needed lines
/^exit$/d
/^eif$/d
/^else$/d
/^step.*then$/d
/process.*snode\=.*/d
/step_err/d
/^pend/d
/^submit.*/d
/^Direct/d
/^Connect/d
/^to.*file/d
/error/d
/failed/d
/^step01/d
/^step02/d
/^step03/d
/^step04/d
/^step05/d
/^step_err/d
# Remove trailing string
s|\.wait.*lly\\"||
# Remove leading string
s|^run.*info\:|File\:|
# Ident the Process lines
s/\(Process Submitted.*\)/      \1/
s/\(Return code.*\)/      \1/
s/\(Message id.*\)/      \1/
# Insert a blank line
/Message id/a\
    ' $1 |  sed -e '
/^[ \t]*$/d
/^0<</d
s/Process.*Number[ \t]*=[ \t]*/PNUM=/
s/Return.*code[ \t]*=[ \t]*/RCODE=/
s/Message.*=[ \t]*/MSGID=/
$!N;/^\(.*\)\n\1$/!P; D'
# 's/Process.*Number[ \t]*=[ \t]*/PNUM=/;s/Return.*code[ \t]*=[ \t]*/RCODE=/;s/Message.*=[ \t]*/MSGID=/'
