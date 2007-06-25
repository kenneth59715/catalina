#!/bin/sh
# Script to generate example Makefile
# Written by Martin Margo, modified by Kenneth Yoshimoto

# avoid using single-quoted strings with backslashes these are handled
# inconsistently by /bin/sh on different platforms.

old_path=$PATH
export old_path
PATH=/bin:/usr/bin
export PATH

# Test quoting
if [ '\\' = "\\" ]
then
	SINGLE_QUOTED_BACKSLASHES=1
else
	SINGLE_QUOTED_BACKSLASHES=2
fi

WHICH=`which which`
if test -x ${WHICH}
then
	echo Using ${WHICH}
else
	echo ERROR: ${WHICH} is not an executable
	echo Exiting...
	exit 1
fi
SED=`${WHICH} sed`
if test -x ${SED}
then
	echo Using ${SED}
else
	echo ERROR: ${SED} is not an executable
	echo Exiting...
	exit 1
fi
ECHO=`${WHICH} echo`
if test -x ${ECHO}
then
	echo Using ${ECHO}
else
	echo ERROR: ${ECHO} is not an executable
	echo Exiting...
	exit 1
fi

get_first_exe() # Returns the path to the first real executable 
{
	for i in `${ECHO} ${old_path} | ${SED}	's/^:/.:/
						s/::/:.:/g
						s/:$/:./
						s/:/ /g'`
	do
		if test -x $i/$1
		then
			${ECHO} $i/$1
			return 0
		fi
	done
	${ECHO} ERROR: $1 not found in ${PATH}
	exit 1
}

bailout()
{
        ${ECHO} $1
        exit $2
}

BASENAME=`get_first_exe basename` || bailout 'Could not find basename' 1
DIRNAME=`get_first_exe dirname` || bailout 'Could not find dirname' 1
PWD=`get_first_exe pwd` || bailout 'Could not find pwd' 1
HOSTNAME_CMD=`get_first_exe hostname` || bailout 'Could not find hostname' 1
HOSTNAME=`${HOSTNAME_CMD}`
${ECHO} "# Site-specific:" > Makefile || bailout 'ERROR: Could not create Makefile!' 1

#these paths needs to be sanitize for trailing '/' e.g. /foo/bar/ --> /foo/bar
MANPATH=${CATALINA_MANPATH-`${PWD}`/test/man}
MANPATH=`${DIRNAME} $MANPATH`/`${BASENAME} $MANPATH`
${ECHO} "MANPATH=${MANPATH}" >> Makefile
HOMEDIR=${CATALINA_INSTALLDIR-`${PWD}`/test/install}
HOMEDIR=`${DIRNAME} $HOMEDIR`/`${BASENAME} $HOMEDIR`
${ECHO} "INSTALLDIR=${HOMEDIR}" >> Makefile
ARCHIVEDIR=${CATALINA_ARCHIVEDIR-`${PWD}`/test/archive}
ARCHIVEDIR=`${DIRNAME} $ARCHIVEDIR`/`${BASENAME} $ARCHIVEDIR`
${ECHO} "ARCHIVEDIR=${ARCHIVEDIR}" >> Makefile
DBDIR=${CATALINA_DBDIR-`${PWD}`/test/db}
DBDIR=`${DIRNAME} $DBDIR`/`${BASENAME} $DBDIR`
${ECHO} "DBDIR=${DBDIR}" >> Makefile
CLUSTER_NAME=${CLUSTER_NAME}
${ECHO} "CLUSTER_NAME=${CLUSTER_NAME}" >> Makefile

# User must set environment variable RESOURCEMANAGER to something
${ECHO} Using RESOURCEMANAGER: ${RESOURCEMANAGER?' ERROR: must be set'}
${ECHO} "" >> Makefile
${ECHO} "# resource manager settings" >> Makefile
DEFAULT_JOB_CLASS=${CATALINA_DEFAULT_JOB_CLASS?ERROR: CATALINA_DEFAULT_JOB_CLASS not set!}
DEFAULT_JOB_QOS=${CATALINA_DEFAULT_JOB_QOS-2}
case ${RESOURCEMANAGER} in
LL)
	${ECHO} "RESOURCEMANAGER=LL" >> Makefile ;
	${ECHO} "RMLIBDIRS=${CATALINA_RMLIBDIRS--L/usr/lpp/LoadL/full/lib}" >> Makefile ;
	${ECHO} "RMINCDIRS=${CATALINA_RMINCDIRS--I/usr/lpp/LoadL/full/include}" >> Makefile ;
	${ECHO} "RMLIBS=-lllapi -lm" >> Makefile ;
	RMSERVER_DEFAULT='' ;
	JOB_START_TIME_LIMIT=900.0 ;
	DB_WARN_LIMIT=3 ;
	JOB_START_WARN_LIMIT=3 ;
	RESOURCE_DOWN_TIME_LIMIT=900.0 ;
	LOST_JOB_LIMIT=1800 ;
	LOST_JOB_WARN=TRUE ;
        if [ "${CATALINA_BUILDMODE}" = "SIM" ]; then
		SUBMITCMD=${CATALINA_SUBMITCMD-`get_first_exe llsubmit_sim`} || bailout 'Could not find llsubmit' 1 ;
		CANCELCMD=${CATALINA_CANCELCMD-`get_first_exe llcancel_sim`} || bailout 'Could not find llcancel' 1 ;
		PREEMPTCMD=${CATALINA_PREEMPTCMD-`get_first_exe llpreempt_sim`} || bailout 'Could not find llpreempt' 1 ;
	else
		SUBMITCMD=${CATALINA_SUBMITCMD-`get_first_exe llsubmit`} || bailout 'Could not find llsubmit' 1 ;
		CANCELCMD=${CATALINA_CANCELCMD-`get_first_exe llcancel`} || bailout 'Could not find llcancel' 1 ;
		PREEMPTCMD=${CATALINA_PREEMPTCMD-`get_first_exe llpreempt`} || bailout 'Could not find llpreempt' 1 ;
	fi
	TESTJOB=testjob.LL ;
	TESTJOB_RUN_AT_RISK=testjob.run_at_risk.LL ;
	USERNAMESUFFIX= ;
	LOADL_ADMIN_FILE=${CATALINA_LOADL_ADMIN_FILE?ERROR: CATALINA_LOADL_ADMIN_FILE not set!} ;
	RM_TO_CAT_RESOURCE_DICT_STRING="{\\
  \"None\" : \"None\",\\
  \"Idle\" : \"Idle\",\\
  \"Down\" : \"Down\",\\
  \"Drain\" : \"Drain\",\\
  \"Draining\" : \"Draining\",\\
  \"Busy\" : \"Running\",\\
  \"Running\" : \"Running\",\\
  \"Starting\" : \"Running\"\\
  }" ;
	RM_TO_CAT_JOB_DICT_STRING="{\\
  \"submittime\" : \"Submit_Time\",\\
  \"Running\" : \"Running\",\\
  \"Canceled\" : \"Canceled\",\\
  \"Completed\" : \"Completed\",\\
  \"Removed\" : \"Removed\",\\
  \"Remove_Pending\" : \"Running\",\\
  \"Starting\" : \"Running\",\\
  \"Preempted\" : \"Preempted\",\\
  \"Preempt_Pending\" : \"Preempted\",\\
  \"Resume_Pending\" : \"Running\",\\
  \"Hold\" : \"Hold\",\\
  \"Idle\" : \"Idle\"\\
  }" ;
	NODERESTCODE_STRING="\\
 import string\\
 resource = input_tuple[0]\\
 if resource[\"State\"] == \"Down\" : result = \"Down\"\\
 elif resource[\"State\"] == \"Drain\" : result = \"Drain\"\\
 elif resource[\"State\"] == \"Drained\" : result = \"Drained\"\\
 elif resource[\"State\"] == \"None\" : result = \"None\"\\
 elif resource[\"State\"] == None : result = None\\
 elif resource[\"State\"] == \"Unknown\" : result = \"Unknown\"\\
 elif resource[\"Max_Starters\"] == 0 : result = \"Max_Starters=0\"\\
 else : result = 0" ;;

PBS)
	${ECHO} "RESOURCEMANAGER=PBS" >> Makefile ;
	${ECHO} "RMLIBDIRS=${CATALINA_RMLIBDIRS--L/usr/local/lib}" >> Makefile ;
	${ECHO} "RMINCDIRS=${CATALINA_RMINCDIRS--I/usr/local/include}" >> Makefile ;
	${ECHO} "RMLIBS=-lpbs" >> Makefile ;
	USERNAMESUFFIX=@${CATALINA_PBS_SUBMITHOST?CATALINA_PBS_SUBMITHOST must be set to the machine on which users will set reservations!} ;
	JOB_START_TIME_LIMIT=5.0 ;
	DB_WARN_LIMIT=3 ;
	JOB_START_WARN_LIMIT=0 ;
	RESOURCE_DOWN_TIME_LIMIT=900.0 ;
	LOST_JOB_LIMIT=0 ;
	LOST_JOB_WARN=FALSE ;
	RMSERVER_DEFAULT=$PBS_DEFAULT || bailout 'Could not find $PBS_DEFAULT' 1 ;
	SUBMITCMD=${CATALINA_SUBMITCMD-`get_first_exe qsub`} || bailout 'Could not find qsub' 1 ;
	CANCELCMD=${CATALINA_CANCELCMD-`get_first_exe qdel`} || bailout 'Could not find qdel' 1 ;
	PREEMPTCMD=${CATALINA_PREEMPTCMD-`get_first_exe qstat`} || bailout 'Could not find qstat' 1 ;
	TESTJOB=testjob.PBS ;
	TESTJOB_RUN_AT_RISK=testjob.run_at_risk.PBS ;
	LOADL_ADMIN_FILE= ;
	RM_TO_CAT_RESOURCE_DICT_STRING="{\\
  \"free\" : \"Idle\",\\
  \"Idle\" : \"Idle\",\\
  \"Down\" : \"Down\",\\
  \"down\" : \"Down\",\\
  \"offline\" : \"Down\",\\
  \"state-unknown,down\" : \"Down\",\\
  \"busy\" : \"Running\",\\
  \"Running\" : \"Running\",\\
  \"job-exclusive\" : \"Running\",\\
  \"job-sharing\" : \"Running\"\\
  }" ;
	RM_TO_CAT_JOB_DICT_STRING="{\\
  \"qtime\" : \"Submit_Time\",\\
  \"R\" : \"Running\",\\
  \"E\" : \"Running\",\\
  \"H\" : \"Hold\",\\
  \"Q\" : \"Idle\",\\
  \"S\" : \"Hold\",\\
  \"T\" : \"Hold\",\\
  \"W\" : \"Hold\"\\
  }" ;
	NODERESTCODE_STRING="\\
 import string\\
 resource = input_tuple[0]\\
 if resource[\"State\"] == \"Down\" : result = \"Down\"\\
 elif resource[\"State\"] == \"Drain\" : result = \"Drain\"\\
 elif resource[\"State\"] == \"Drained\" : result = \"Drained\"\\
 elif resource[\"State\"] == \"None\" : result = \"None\"\\
 elif resource[\"State\"] == None : result = None\\
 elif resource[\"State\"] == \"Unknown\" : result = \"Unknown\"\\
 else : result = 0" ;;

TORQUE)
	${ECHO} "RESOURCEMANAGER=PBS" >> Makefile ;
	RESOURCEMANAGER=PBS ;
	${ECHO} "RMLIBDIRS=${CATALINA_RMLIBDIRS--L/usr/local/lib}" >> Makefile ;
	${ECHO} "RMINCDIRS=${CATALINA_RMINCDIRS--I/usr/local/include}" >> Makefile ;
	${ECHO} "RMLIBS=-ltorque" >> Makefile ;
	USERNAMESUFFIX=@${CATALINA_PBS_SUBMITHOST?CATALINA_PBS_SUBMITHOST must be set to the machine on which users will set reservations!} ;
	JOB_START_TIME_LIMIT=5.0 ;
	DB_WARN_LIMIT=3 ;
	JOB_START_WARN_LIMIT=0 ;
	RESOURCE_DOWN_TIME_LIMIT=900.0 ;
	LOST_JOB_LIMIT=0 ;
	LOST_JOB_WARN=FALSE ;
	RMSERVER_DEFAULT=$PBS_DEFAULT || bailout 'Could not find $PBS_DEFAULT' 1 ;
	SUBMITCMD=${CATALINA_SUBMITCMD-`get_first_exe qsub`} || bailout 'Could not find qsub' 1 ;
	CANCELCMD=${CATALINA_CANCELCMD-`get_first_exe qdel`} || bailout 'Could not find qdel' 1 ;
	PREEMPTCMD=${CATALINA_PREEMPTCMD-`get_first_exe qstat`} || bailout 'Could not find qstat' 1 ;
	TESTJOB=testjob.PBS ;
	TESTJOB_RUN_AT_RISK=testjob.run_at_risk.PBS ;
	LOADL_ADMIN_FILE= ;
	RM_TO_CAT_RESOURCE_DICT_STRING="{\\
  \"free\" : \"Idle\",\\
  \"Idle\" : \"Idle\",\\
  \"Down\" : \"Down\",\\
  \"down\" : \"Down\",\\
  \"offline\" : \"Down\",\\
  \"state-unknown,down\" : \"Down\",\\
  \"busy\" : \"Running\",\\
  \"Running\" : \"Running\",\\
  \"job-exclusive\" : \"Running\",\\
  \"job-sharing\" : \"Running\"\\
  }" ;
	RM_TO_CAT_JOB_DICT_STRING="{\\
  \"qtime\" : \"Submit_Time\",\\
  \"R\" : \"Running\",\\
  \"E\" : \"Running\",\\
  \"H\" : \"Hold\",\\
  \"Q\" : \"Idle\",\\
  \"S\" : \"Hold\",\\
  \"T\" : \"Hold\",\\
  \"W\" : \"Hold\"\\
  }" ;
	NODERESTCODE_STRING="\\
 import string\\
 resource = input_tuple[0]\\
 if resource[\"State\"] == \"Down\" : result = \"Down\"\\
 elif resource[\"State\"] == \"Drain\" : result = \"Drain\"\\
 elif resource[\"State\"] == \"Drained\" : result = \"Drained\"\\
 elif resource[\"State\"] == \"None\" : result = \"None\"\\
 elif resource[\"State\"] == None : result = None\\
 elif resource[\"State\"] == \"Unknown\" : result = \"Unknown\"\\
 else : result = 0" ;;

DISK)
	${ECHO} "RESOURCEMANAGER=DISK" >> Makefile ;
	${ECHO} "RMLIBDIRS=${CATALINA_RMLIBDIRS--L/usr/local/lib}" >> Makefile ;
	${ECHO} "RMINCDIRS=${CATALINA_RMINCDIRS--I/usr/local/include}" >> Makefile ;
	${ECHO} "RMLIBS=" >> Makefile ;
	USERNAMESUFFIX='' ;
	JOB_START_TIME_LIMIT=5.0 ;
	DB_WARN_LIMIT=3 ;
	JOB_START_WARN_LIMIT=0 ;
	RESOURCE_DOWN_TIME_LIMIT=900.0 ;
	LOST_JOB_LIMIT=0 ;
	LOST_JOB_WARN=FALSE ;
	SUBMITCMD=${CATALINA_SUBMITCMD-`get_first_exe cat`} || bailout 'Could not find cat' 1 ;
	CANCELCMD=${CATALINA_CANCELCMD-`get_first_exe cat`} || bailout 'Could not find cat' 1 ;
	TESTJOB=testjob.DISK ;
	TESTJOB_RUN_AT_RISK=testjob.run_at_risk.DISK ;
	LOADL_ADMIN_FILE= ;;

*)	${ECHO} RESOURCEMANAGER must be set to either LL or PBS ; exit 1 ;;
esac

DEF_CLASS_PRIORITY_DICT_STRING="{\\
  \"interactive\" : 1.8,\\
  \"premium\" : 1.0,\\
  \"express\" : 1.8,\\
  \"high\" : 1.8,\\
  \"normal\" : 1.0,\\
  \"standard\" : 1.0,\\
  \"low\" : 0.5,\\
  \"standby\" : 0.0,\\
  \"legion\" : 0.0,\\
  \"WH\" : 0.0,\\
  \"Diag\" : 0.0,\\
  \"Diag0\" : 0.0,\\
  \"Diag1\" : 0.0,\\
  \"Diag2\" : 0.0,\\
  \"Diag3\" : 0.0,\\
  \"Diag4\" : 0.0,\\
  \"Diag5\" : 0.0,\\
  \"Diag6\" : 0.0,\\
  \"Diag7\" : 0.0,\\
  \"Diag8\" : 0.0,\\
  \"Diag9\" : 0.0\\
  }"

DEF_DEFAULT_RES_CLASS=express
DEF_DEFAULT_PROC_CHARGE=8


FORCETZ=${CATALINA_FORCETZ-'NOFORCE'}
${ECHO} "RMCFLAGS= -g ${CATALINA_RMCFLAGS} \$(RMLIBDIRS) \$(RMINCDIRS)" >> Makefile
${ECHO} "RMSERVER_DEFAULT=${RMSERVER_DEFAULT}" >> Makefile
${ECHO} "" >> Makefile
WHOAMI=`get_first_exe whoami` || bailout 'Could not find whoami' 1
CATOWNER=${CATALINA_CATOWNER-`${WHOAMI}`}
${ECHO} "CATOWNER=${CATOWNER}" >> Makefile
${ECHO} "# user to own lock files, enables database write" >> Makefile
${ECHO} "CATLOCKOWNER=${CATALINA_CATLOCKOWNER-\$(CATOWNER)}" >> Makefile
${ECHO} "# group to own lock files, enables database write" >> Makefile
ID=`get_first_exe id` || bailout 'Could not find id' 1
${ID} -gn
case $? in
0)	${ECHO} id -gn works... ;;
*)	${ECHO} ERROR id -gn failed! ; exit 1 ;;
esac
CATGROUP=${CATALINA_CATLOCKGROUP-`${ID} -gn`}
${ECHO} "CATLOCKGROUP=${CATGROUP}" >> Makefile
${ECHO} "# This is the owner of the user_* files" >> Makefile
${ECHO} "# for Blue Horizon, this can be anyone, since the file will use" >> Makefile
TESTACCOUNT=${CATALINA_TESTACCOUNT-`${ID} -gn`}

${ECHO} "# setgid security for obtaining db writing privileges" >> Makefile

${ECHO} "CATUSEROWNER=${CATALINA_CATUSEROWNER-\$(CATOWNER)}" >> Makefile
${ECHO} "CATUSERGROUP=${CATALINA_CATUSERGROUP-\$(CATLOCKGROUP)}" >> Makefile
${ECHO} "# CATPERMS is the permissions for the user_* commands" >> Makefile
${ECHO} "# For Blue Horizon, it should be 2755, since it's sufficient to be" >> Makefile
${ECHO} "# setgid security to write to the db" >> Makefile
${ECHO} "#CATUSERPERMS=2755" >> Makefile
${ECHO} "CATUSERPERMS=${CATALINA_CATUSERPERMS-755}" >> Makefile
${ECHO} "#CATUSERCFLAGS=-D__USE_UNIX98 -D_SIGNAL_H " >> Makefile
${ECHO} "CATUSERCFLAGS=${CATALINA_CATUSERFLAGS-}" >> Makefile
if [ ${CATALINA_PYTHONPATH} ]
then
	${ECHO} Using ${CATALINA_PYTHONPATH}
	${ECHO} "PYTHONPATH=${CATALINA_PYTHONPATH}" >> Makefile
	PYTHONPATH=${CATALINA_PYTHONPATH}
else
	PYTHONPATH=`get_first_exe python` || bailout 'ERROR: Could not find python' 1
	${PYTHONPATH} -c 'print "hello"'
	case $? in
	0)	${ECHO} ${PYTHONPATH} hello works... ;;
	*)	${ECHO} ERROR ${PYTHONPATH} hello failed! ; exit 1 ;;
	esac
	${ECHO} "PYTHONPATH=${PYTHONPATH}" >> Makefile
fi
KSH=`get_first_exe ksh` || bailout 'Could not find ksh' 1
${KSH} -c 'echo hello'
case $? in
0)	${ECHO} ksh hello works... ;;
*)	${ECHO} ERROR ksh hello failed! ; exit 1 ;;
esac
${ECHO} "KSHPATH=${KSH}" >> Makefile #/usr/bin/ksh
if [ ${CC} ]
then
	${ECHO} Using ${CC}
	${ECHO} "CC=${CC}" >> Makefile
else
	GCCPATH=`get_first_exe gcc` || bailout 'ERROR: Could not find gcc' 1
	${GCCPATH} --help > /dev/null
	case $? in
	0)	${ECHO} ${GCCPATH} --help works... ;;
	*)	${ECHO} ERROR ${GCCPATH} --help failed! ; exit 1 ;;
	esac
	${ECHO} "CC=${GCCPATH}" >> Makefile
fi
${ECHO} "" >> Makefile
# May need to change these:
${ECHO} "# Platform-specific settings:" >> Makefile
AWK=`get_first_exe awk` || bailout 'Could not find awk' 1
${ECHO} 'and a one' | ${AWK} '{print $3}'
case $? in
0)	${ECHO} awk works... ;;
*)	${ECHO} ERROR awk failed! ; exit 1 ;;
esac
${ECHO} "AWK=${AWK}" >> Makefile #/usr/bin/awk
WC=`get_first_exe wc` || bailout 'Could not find wc' 1
${ECHO} 'and a one' | ${WC}
case $? in
0)	${ECHO} wc works... ;;
*)	${ECHO} ERROR wc failed! ; exit 1 ;;
esac
${ECHO} "WC=${WC}" >> Makefile #/usr/bin/wc
DATE=`get_first_exe date` || bailout 'Could not find date' 1
${DATE} "+%m%d%Y"
case $? in
0)	${ECHO} date works... ;;
*)	${ECHO} ERROR date failed! ; exit 1 ;;
esac
${ECHO} "DATE=${DATE}" >> Makefile #/usr/bin/date
NOHUP=`get_first_exe nohup` || bailout 'Could not find nohup' 1
${NOHUP} ${ECHO} hello
case $? in
0)	${ECHO} nohup works... ;;
*)	${ECHO} ERROR nohup failed! ; exit 1 ;;
esac
${ECHO} "NOHUP=${NOHUP}" >> Makefile #/usr/bin/nohup
SLEEP=`get_first_exe sleep` || bailout 'Could not find sleep' 1
${SLEEP} 1
case $? in
0)	${ECHO} sleep works... ;;
*)	${ECHO} ERROR sleep failed! ; exit 1 ;;
esac
${ECHO} "SLEEP=${SLEEP}" >> Makefile #/usr/bin/sleep
GREP=`get_first_exe grep` || bailout 'Could not find grep' 1
${GREP} root /etc/passwd > /dev/null
case $? in
0)	${ECHO} grep works... ;;
*)	${ECHO} ERROR grep failed! ; exit 1 ;;
esac
${ECHO} "GREP=${GREP}" >> Makefile #/usr/bin/grep
PS=`get_first_exe ps` || bailout 'Could not find ps' 1
${PS} > /dev/null
case $? in
0)	${ECHO} ps works... ;;
*)	${ECHO} ERROR ps failed! ; exit 1 ;;
esac
${ECHO} "PS=${PS}" >> Makefile #/usr/bin/ps
${PS} -ef > /dev/null && PSOPTIONS=-ef
${PS} -ewf > /dev/null && PSOPTIONS=-ewf
${ECHO} "PSOPTIONS=${PSOPTIONS}" >> Makefile
CP=`get_first_exe cp` || bailout 'Could not find cp' 1
${CP} -f Makefile.dist test.$$
case $? in
0)	${ECHO} cp works... ;;
*)	${ECHO} ERROR cp failed! ; exit 1 ;;
esac
${ECHO} "CP=${CP}" >> Makefile
CHMOD=`get_first_exe chmod` || bailout 'Could not find chmod' 1
${CHMOD} 755 test.$$
case $? in
0)	${ECHO} chmod works... ;;
*)	${ECHO} ERROR chmod failed! ; exit 1 ;;
esac
echo "CHMOD=${CHMOD}" >> Makefile
WHOAMI=`get_first_exe whoami` || bailout 'Could not find whoami' 1
CHOWN=`get_first_exe chown` || bailout 'Could not find chown' 1
${CHOWN} `${WHOAMI}` test.$$
case $? in
0)	${ECHO} chown works... ;;
*)	${ECHO} ERROR chown failed! ; exit 1 ;;
esac
echo "CHOWN=${CHOWN}" >> Makefile
MKDIR=`get_first_exe mkdir` || bailout 'Could not find mkdir' 1
${MKDIR} testdir.$$
case $? in
0)	${ECHO} mkdir works... ;;
*)	${ECHO} ERROR mkdir failed! ; exit 1 ;;
esac
echo "MKDIR=${MKDIR}" >> Makefile
SED=`get_first_exe sed` || bailout 'Could not find sed' 1
${SED} 's/RESOURCEMANAGER/NEW/' test.$$ > /dev/null
case $? in
0)	${ECHO} sed works... ;;
*)	${ECHO} ERROR sed failed! ; exit 1 ;;
esac
echo "SED=${SED}" >> Makefile
CAT=`get_first_exe cat` || bailout 'Could not find cat' 1
${CAT} test.$$ > /dev/null
case $? in
0)	${ECHO} cat works... ;;
*)	${ECHO} ERROR cat failed! ; exit 1 ;;
esac
echo "CAT=${CAT}" >> Makefile
FIND=`get_first_exe find` || bailout 'Could not find find' 1
${FIND} test.$$ -name test.$$ -print
case $? in
0)	${ECHO} find works... ;;
*)	${ECHO} ERROR find failed! ; exit 1 ;;
esac
echo "FIND=${FIND}" >> Makefile #/usr/bin/find
MV=`get_first_exe mv` || bailout 'Could not find mv' 1
${CAT} Makefile.dist > mv.test
${MV} mv.test mv.test.2
case $? in
0)	${ECHO} mv works... ;;
*)	${ECHO} ERROR mv failed! ; exit 1 ;;
esac
${ECHO} "MV=${MV}" >> Makefile
RM=`get_first_exe rm` || bailout 'Could not find rm' 1
${RM} test.$$
case $? in
0)	${ECHO} rm works... ;;
*)	${ECHO} ERROR rm failed! ; exit 1 ;;
esac
${ECHO} "RM=${RM}" >> Makefile
RMDIR=`get_first_exe rmdir` || bailout 'Could not find rmdir' 1
${RMDIR} testdir.$$

MAILX=`get_first_exe mailx` || MAILX=`get_first_exe mail` || bailout 'Could not find mail' 1
${ECHO} testing... | ${MAILX} -s "Catalina is testing mail functionality" ${CATOWNER}
case $? in
0)	${ECHO} mail works... ;;
*)	${ECHO} ERROR mail failed! ; exit 1 ;;
esac
LOGGER=`get_first_exe logger` || LOGGER=`get_first_exe logger` || bailout 'Could not find logger' 1
${LOGGER} -t CATALINA -p daemon.debug 'testing logger...'
case $? in
0)	${ECHO} logger works... ;;
*)	${ECHO} ERROR logger failed! ; exit 1 ;;
esac
LOGGER_FACILITY=daemon

${ECHO} "s@___NODERESTCODE_STRING_PLACEHOLDER___@${NODERESTCODE_STRING}@g" > sedscr
${ECHO} "s@___RESLIST_CMD_PLACEHOLDER___@${CATALINA_RESLIST-${HOMEDIR}/reslist}@g" >> sedscr
${ECHO} "s#___MAIL_RECIPIENT_PLACEHOLDER___#${CATALINA_MAIL_RECIPIENT-${CATOWNER}}#g" >> sedscr
${ECHO} "s#___USER_SET_RECIPIENT_PLACEHOLDER___#${CATALINA_USER_SET_RECIPIENT-${CATOWNER}}#g" >> sedscr
${ECHO} "s#___PROLOGUE_RES_PLACEHOLDER___#${CATALINA_PROLOGUE_RES-${HOMEDIR}/prologue.res}#g" >> sedscr
${ECHO} "s#___EPILOGUE_RES_PLACEHOLDER___#${CATALINA_EPILOGUE_RES-${HOMEDIR}/prologue.res}#g" >> sedscr
${ECHO} "s@___MAILX_PLACEHOLDER___@${CATALINA_MAILX-${MAILX}}@g" >> sedscr
${ECHO} "s@___LOGGER_PLACEHOLDER___@${CATALINA_LOGGER-${LOGGER}}@g" >> sedscr
${ECHO} "s@___LOGGER_FACILITY_PLACEHOLDER___@${CATALINA_LOGGER_FACILITY-${LOGGER_FACILITY}}@g" >> sedscr
${ECHO} "s#___TEST_MAIL_RECIPIENT_PLACEHOLDER___#${CATALINA_TEST_MAIL_RECIPIENT-${CATOWNER}@${HOSTNAME}}#g" >> sedscr
${ECHO} "s@___TESTACCOUNT_PLACEHOLDER___@${CATALINA_TESTACCOUNT-${TESTACCOUNT}}@g" >> sedscr
${ECHO} "s@___ECHO_PLACEHOLDER___@${ECHO}@g" >> sedscr
${ECHO} "s@___FORCETZ_PLACEHOLDER___@${FORCETZ}@g" >> sedscr
${ECHO} "s@___CAT_LOCK_OWNER_PLACEHOLDER___@${CATOWNER}@g" >> sedscr
${ECHO} "s@___CAT_LOCK_GROUP_PLACEHOLDER___@${CATGROUP}@g" >> sedscr
${ECHO} "s@___INSTALLDIR_PLACEHOLDER___@${HOMEDIR}@g" >> sedscr
${ECHO} "s@___DBDIR_PLACEHOLDER___@${DBDIR}@g" >> sedscr
${ECHO} "s@___ARCHIVEDIR_PLACEHOLDER___@${ARCHIVEDIR}@g" >> sedscr
${ECHO} "s@___JOB_START_TIME_LIMIT_PLACEHOLDER___@${JOB_START_TIME_LIMIT}@g" >> sedscr
${ECHO} "s@___DB_WARN_LIMIT_PLACEHOLDER___@${DB_WARN_LIMIT}@g" >> sedscr
${ECHO} "s@___JOB_START_WARN_LIMIT_PLACEHOLDER___@${JOB_START_WARN_LIMIT}@g" >> sedscr
${ECHO} "s@___RESOURCE_DOWN_TIME_LIMIT_PLACEHOLDER___@${RESOURCE_DOWN_TIME_LIMIT}@g" >> sedscr
${ECHO} "s@___LOST_JOB_LIMIT_PLACEHOLDER___@${LOST_JOB_LIMIT}@g" >> sedscr
${ECHO} "s@___LOST_JOB_WARN_PLACEHOLDER___@${LOST_JOB_WARN}@g" >> sedscr
${ECHO} "s@___SUBMITCMD_PLACEHOLDER___@${SUBMITCMD}@g" >> sedscr
${ECHO} "s@___CANCELCMD_PLACEHOLDER___@${CANCELCMD}@g" >> sedscr
${ECHO} "s@___TEST_JOB_PLACEHOLDER___@${TESTJOB}@g" >> sedscr
${ECHO} "s@___TEST_JOB_RUN_AT_RISK_PLACEHOLDER___@${TESTJOB_RUN_AT_RISK}@g" >> sedscr
${ECHO} "s#___USERNAMESUFFIX_PLACEHOLDER___#${USERNAMESUFFIX}#g" >> sedscr
${ECHO} "s@___LOADL_ADMIN_FILE_PLACEHOLDER___@${LOADL_ADMIN_FILE}@g" >> sedscr
${ECHO} "s@___RM_TO_CAT_RESOURCE_DICT_STRING_PLACEHOLDER___@${RM_TO_CAT_RESOURCE_DICT_STRING}@g" >> sedscr
${ECHO} "s@___RM_TO_CAT_JOB_DICT_STRING_PLACEHOLDER___@${RM_TO_CAT_JOB_DICT_STRING}@g" >> sedscr
${ECHO} "s@___CLASS_PRIORITY_DICT_STRING_STRING_PLACEHOLDER___@${CATALINA_CLASS_PRIORITY_DICT_STRING-${DEF_CLASS_PRIORITY_DICT_STRING}}@g" >> sedscr
${ECHO} "s@___DEFAULT_RES_CLASS_PLACEHOLDER___@${CATALINA_DEFAULT_RES_CLASS-${DEF_DEFAULT_RES_CLASS}}@g" >> sedscr
${ECHO} "s@___DEFAULT_PROC_CHARGE_PLACEHOLDER___@${CATALINA_DEFAULT_PROC_CHARGE-${DEF_DEFAULT_PROC_CHARGE}}@g" >> sedscr
${ECHO} "s@___DEFAULT_JOB_CLASS_PLACEHOLDER___@${DEFAULT_JOB_CLASS}@g" >> sedscr

#STTY=`get_first_exe stty` || bailout 'Could not find stty' 1
#case $? in
#0)	${ECHO} stty works... ;;
#*)	${ECHO} ERROR stty failed! ; exit 1 ;;
#esac
#echo "STTY=`which stty`" >> Makefile #/usr/bin/stty
${ECHO} "" >> Makefile
# Should not need to change anything below
${ECHO} "# Should not need to change anything below" >> Makefile
${ECHO} "SHELL=/bin/sh" >> Makefile
${ECHO} "CATALINA=Catalina.py" >> Makefile
${ECHO} "CATALINA_RM=Catalina_\$(RESOURCEMANAGER).py" >> Makefile
${ECHO} "BINDJOB=bind_job_to_res" >> Makefile
${ECHO} "CANCELRES=cancel_res" >> Makefile
${ECHO} "CANCELSTANDING=cancel_standing_res" >> Makefile
${ECHO} "CHECKPY=check.py" >> Makefile
${ECHO} "CHANGELOG=CHANGELOG" >> Makefile
${ECHO} "COPYRIGHT=COPYRIGHT" >> Makefile
${ECHO} "DATESTAMP=DATESTAMP" >> Makefile
${ECHO} "VERSIONHASH=VERSIONHASH" >> Makefile
${ECHO} "RELEASE=release" >> Makefile
${ECHO} "CREATERES=create_res" >> Makefile
${ECHO} "CREATESTANDING=create_standing_res" >> Makefile
${ECHO} "CREATESYSTEM=create_system_res" >> Makefile
${ECHO} "DELJOB=del_job" >> Makefile
${ECHO} "DELPIDS=del_pids" >> Makefile
${ECHO} "FIRSTAVAILABLE=first_available" >> Makefile
${ECHO} "INITIALIZE=initialize_dbs" >> Makefile
${ECHO} "LASTAVAIL=last_available" >> Makefile
${ECHO} "LOADCONFIGURED=load_configured_resources" >> Makefile
${ECHO} "MOVEOLD=move_old_stuff" >> Makefile
${ECHO} "NODEREST=node_restriction_file.\$(RESOURCEMANAGER)" >> Makefile
${ECHO} "NONCONFLICTING=nonconflicting" >> Makefile
if [ "${CATALINA_BUILDMODE}" = "SIM" ]; then
	${ECHO} "QJ=qj_\$(RESOURCEMANAGER)_sim" >> Makefile
	QJ=qj_${RESOURCEMANAGER}_sim
	${ECHO} "QM=qm_\$(RESOURCEMANAGER)_sim" >> Makefile
	QM=qm_${RESOURCEMANAGER}_sim
	${ECHO} "RUNJOB=rj_\$(RESOURCEMANAGER)_sim" >> Makefile
	RUNJOB=rj_${RESOURCEMANAGER}_sim
	${ECHO} "PREEMPTJOB=pj_\$(RESOURCEMANAGER)_sim" >> Makefile
	PREEMPTJOB=pj_${RESOURCEMANAGER}_sim
	${ECHO} "RESUMEJOB=resj_\$(RESOURCEMANAGER)_sim" >> Makefile
	RESUMEJOB=resj_${RESOURCEMANAGER}_sim
else
	${ECHO} "QJ=qj_\$(RESOURCEMANAGER)" >> Makefile
	QJ=qj_${RESOURCEMANAGER}
	${ECHO} "QM=qm_\$(RESOURCEMANAGER)" >> Makefile
	QM=qm_${RESOURCEMANAGER}
	${ECHO} "RUNJOB=rj_\$(RESOURCEMANAGER)" >> Makefile
	RUNJOB=rj_${RESOURCEMANAGER}
	${ECHO} "PREEMPTJOB=pj_\$(RESOURCEMANAGER)" >> Makefile
	PREEMPTJOB=pj_${RESOURCEMANAGER}
	${ECHO} "RESUMEJOB=resj_\$(RESOURCEMANAGER)" >> Makefile
	RESUMEJOB=resj_${RESOURCEMANAGER}
fi

${ECHO} "s@___PYTHON_PATH_PLACEHOLDER___@${PYTHONPATH}@g"  >sedscrb
${ECHO} "s@___HOMEDIR_PLACEHOLDER___@${HOMEDIR}@g"  >>sedscrb
${ECHO} "s@___DBDIR_PLACEHOLDER___@${DBDIR}@g"  >>sedscrb
${ECHO} "s@___ARCHIVEDIR_PLACEHOLDER___@${ARCHIVEDIR}@g"  >>sedscrb
${ECHO} "s@___RESOURCEMANAGER_PLACEHOLDER___@${RESOURCEMANAGER}@g"  >>sedscrb
${ECHO} "s@___RMSERVER_DEFAULT_PLACEHOLDER___@${RMSERVER_DEFAULT}@g"  >>sedscrb
${ECHO} "s@___QJ_PLACEHOLDER___@${QJ}@g"  >>sedscrb
${ECHO} "s@___QM_PLACEHOLDER___@${QM}@g"  >>sedscrb
${ECHO} "s@___RUNJOB_PLACEHOLDER___@${RUNJOB}@g"  >>sedscrb
${ECHO} "s@___PREEMPTJOB_PLACEHOLDER___@${PREEMPTJOB}@g"  >>sedscrb
${ECHO} "s@___RESUMEJOB_PLACEHOLDER___@${RESUMEJOB}@g"  >>sedscrb
${ECHO} "s@___PS_PLACEHOLDER___@${PS}@g"  >>sedscrb
${ECHO} "s@___PSOPTIONS_PLACEHOLDER___@${PSOPTIONS}@g"  >>sedscrb
${ECHO} "s@___GREP_PLACEHOLDER___@${GREP}@g"  >>sedscrb
${ECHO} "s@___CAT_PLACEHOLDER___@${CAT}@g"  >>sedscrb
${ECHO} "s@___WC_PLACEHOLDER___@${WC}@g"  >>sedscrb
${ECHO} "s@___AWK_PLACEHOLDER___@${AWK}@g"  >>sedscrb
${ECHO} "s@___DATE_PLACEHOLDER___@${DATE}@g"  >>sedscrb
${ECHO} "s@___NOHUP_PLACEHOLDER___@${NOHUP}@g"  >>sedscrb

${ECHO} "QPRIORITY=query_priority" >> Makefile
${ECHO} "RESLIST=reslist" >> Makefile
${ECHO} "PROLOGUERES=prologue.res" >> Makefile
${ECHO} "EPILOGUERES=epilogue.res" >> Makefile
${ECHO} "RESPROEPI=resproepi" >> Makefile
${ECHO} "RESSTATUS=res_status" >> Makefile
${ECHO} "RUNNINGFIRST=last_available_running_first" >> Makefile
${ECHO} "SCHEDULEJOBS=catalina_schedule_jobs" >> Makefile
${ECHO} "SCRATCHTEST=scratchtest.py" >> Makefile
${ECHO} "SETCONFIG=set_config" >> Makefile
${ECHO} "SETRES=set_res" >> Makefile
${ECHO} "SHOWFREE=show_free" >> Makefile
${ECHO} "SHOWBF=show_bf" >> Makefile
${ECHO} "SHOWBFALL=show_bf-all" >> Makefile
${ECHO} "SHOWCONFIG=show_config" >> Makefile
${ECHO} "SHOWEVENTS=show_events" >> Makefile
${ECHO} "SHOWGUESS=show_guesstimate" >> Makefile
${ECHO} "SHOWQ=show_q" >> Makefile
${ECHO} "SHOWRES=show_res" >> Makefile
${ECHO} "SHOWRESOURCES=show_resources" >> Makefile
${ECHO} "DUMP=dump" >> Makefile
${ECHO} "SHOWSTANDING=show_standing_res" >> Makefile
${ECHO} "START=start.ksh" >> Makefile
${ECHO} "STOP=stop.py" >> Makefile
${ECHO} "TESTJOB=${TESTJOB}" >> Makefile
${ECHO} "TESTJOB_RUN_AT_RISK=${TESTJOB_RUN_AT_RISK}" >> Makefile
${ECHO} "TESTRES=testres9.py" >> Makefile
${ECHO} "UNBINDJOB=unbind_job_from_res" >> Makefile
${ECHO} "UPDATEJOBS=update_jobs" >> Makefile
${ECHO} "UPDATELOCALADMIN=update_local_admin" >> Makefile
${ECHO} "UPDATEPRIORITIES=update_job_priorities" >> Makefile
${ECHO} "UPDATEQOS=update_qos" >> Makefile
${ECHO} "UPDATEPREEMPTION=update_preemption" >> Makefile
${ECHO} "UPDATERESOURCES=update_resources" >> Makefile
${ECHO} "UPDATERUNNING=update_runningstarting" >> Makefile
${ECHO} "UPDATESTANDING=update_standing_reservations" >> Makefile
${ECHO} "UPDATESYSTEM=update_system_priority" >> Makefile
${ECHO} "USERBINDWRAP=user_bind_res" >> Makefile
${ECHO} "USERBINDPY=user_bind_res.py" >> Makefile
${ECHO} "USERUNBINDWRAP=user_unbind_res" >> Makefile
${ECHO} "USERUNBINDPY=user_unbind_res.py" >> Makefile
${ECHO} "USERBINDJOBWRAP=user_bind_job" >> Makefile
${ECHO} "USERBINDJOBPY=user_bind_job.py" >> Makefile
${ECHO} "USERUNBINDJOBWRAP=user_unbind_job" >> Makefile
${ECHO} "USERUNBINDJOBPY=user_unbind_job.py" >> Makefile
${ECHO} "USERCANCELWRAP=user_cancel_res" >> Makefile
${ECHO} "USERCANCELPY=user_cancel_res.py" >> Makefile
${ECHO} "USERSETWRAP=user_set_res" >> Makefile
${ECHO} "USERSETPY=user_set_res.py" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "TESTJOB_FILES = \$(TESTJOB) \$(TESTJOB_RUN_AT_RISK)" >> Makefile
${ECHO} "" >> Makefile
if [ "${CATALINA_BUILDMODE}" = "SIM" ]; then
	${ECHO} "C_EXECUTABLE_FILES = \$(USERCANCELWRAP) \$(USERSETWRAP) \$(USERBINDWRAP) \$(USERUNBINDWRAP) \$(USERBINDJOBWRAP) \$(USERUNBINDJOBWRAP)" >> Makefile
else
	${ECHO} "C_EXECUTABLE_FILES = \$(QJ) \$(QM) \$(RUNJOB) \$(PREEMPTJOB) \$(RESUMEJOB) \$(USERCANCELWRAP) \$(USERSETWRAP) \$(USERBINDWRAP) \$(USERUNBINDWRAP) \$(USERBINDJOBWRAP) \$(USERUNBINDJOBWRAP)" >> Makefile
fi
${ECHO} "" >> Makefile
${ECHO} "KSH_EXECUTABLE_FILES = \$(START)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "PY_EXECUTABLE_FILES = \$(BINDJOB) \\" >> Makefile
${ECHO} "	\$(CANCELRES) \$(CANCELSTANDING) \$(CHECKPY) \$(CREATERES) \\" >> Makefile
${ECHO} "	\$(CREATESTANDING) \\" >> Makefile
${ECHO} "	\$(CREATESYSTEM) \$(DELJOB) \$(DELPIDS) \$(INITIALIZE) \$(LOADCONFIGURED) \\" >> Makefile
${ECHO} "	\$(MOVEOLD) \$(QPRIORITY) \$(RELEASE) \$(RESLIST) \$(RESSTATUS) \\" >> Makefile
${ECHO} "	\$(PROLOGUERES) \$(EPILOGUERES) \\" >> Makefile
${ECHO} "	\$(SCHEDULEJOBS) \$(SCRATCHTEST) \\" >> Makefile
${ECHO} "	\$(SETCONFIG) \$(SETRES) \$(SHOWFREE) \$(SHOWBF) \$(SHOWBFALL) \$(SHOWCONFIG) \$(SHOWEVENTS) \\" >> Makefile
${ECHO} "	\$(SHOWGUESS) \$(SHOWQ) \$(SHOWRES) \\" >> Makefile
${ECHO} "	\$(SHOWRESOURCES) \$(DUMP)\\" >> Makefile
${ECHO} "	\$(SHOWSTANDING) \$(STOP) \$(TESTRES) \$(UNBINDJOB) \$(UPDATEJOBS) \\" >> Makefile
${ECHO} "	\$(UPDATELOCALADMIN) \$(UPDATEPREEMPTION) \\" >> Makefile
${ECHO} "	\$(UPDATEPRIORITIES) \$(UPDATEQOS) \$(UPDATERESOURCES) \$(UPDATERUNNING) \\" >> Makefile
${ECHO} "	\$(UPDATESTANDING) \$(RESPROEPI)\\" >> Makefile
${ECHO} "	\$(UPDATESYSTEM) \$(USERBINDPY) \$(USERCANCELPY) \$(USERSETPY) \$(USERUNBINDPY) \$(USERBINDJOBPY) \$(USERUNBINDJOBPY)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "EXECUTABLE_FILES = \$(C_EXECUTABLE_FILES) \$(PY_EXECUTABLE_FILES) \$(KSH_EXECUTABLE_FILES)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "POLICY_FILES = \$(NODEREST) \$(NONCONFLICTING) \$(RUNNINGFIRST) \\" >> Makefile
${ECHO} "	\$(FIRSTAVAILABLE) \$(LASTAVAIL) \$(CHANGELOG) \$(COPYRIGHT) \\" >> Makefile
${ECHO} "	\$(DATESTAMP) \$(VERSIONHASH)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "PRODUCTION_FILES = \$(CATALINA) \$(CATALINA_RM) \$(TESTJOB_FILES) \\" >> Makefile
${ECHO} "	\$(EXECUTABLE_FILES) \$(POLICY_FILES)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "all: MACH_SPECIFIC PYSUB KSHSUB TESTJOBS \$(C_EXECUTABLE_FILES)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "install: all" >> Makefile
${ECHO} "	# Need to also create the initial dbs with the correct" >> Makefile
${ECHO} "	# permissions" >> Makefile
${ECHO} "	if \\" >> Makefile
${ECHO} "		test ! -d \$(INSTALLDIR) ; \\" >> Makefile
${ECHO} "	then \\" >> Makefile
${ECHO} "		\$(MKDIR) -p \$(INSTALLDIR) ; \\" >> Makefile
${ECHO} "		\$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR) ; \\" >> Makefile
${ECHO} "	else \\" >> Makefile
${ECHO} "		\$(CP) -pfr \$(INSTALLDIR) \$(INSTALLDIR).\`\$(DATE) +%Y%m%d%H%M%S\` ; \\" >> Makefile
${ECHO} "	fi" >> Makefile
${ECHO} "	if \\" >> Makefile
${ECHO} "		test ! -d \$(DBDIR) ; \\" >> Makefile
${ECHO} "	then \\" >> Makefile
${ECHO} "		\$(MKDIR) -p \$(DBDIR) ; \\" >> Makefile
${ECHO} "		\$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(DBDIR) ; \\" >> Makefile
${ECHO} "	else \\" >> Makefile
${ECHO} "		\$(CP) -pfr \$(DBDIR) \$(DBDIR).\`\$(DATE) +%Y%m%d%H%M%S\` ; \\" >> Makefile
${ECHO} "	fi" >> Makefile
${ECHO} "	if \\" >> Makefile
${ECHO} "		test ! -d \$(ARCHIVEDIR) ; \\" >> Makefile
${ECHO} "	then \\" >> Makefile
${ECHO} "		\$(MKDIR) -p \$(ARCHIVEDIR) ; \\" >> Makefile
${ECHO} "		\$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(ARCHIVEDIR) ; \\" >> Makefile
${ECHO} "	fi" >> Makefile
${ECHO} "	if \\" >> Makefile
${ECHO} "		test ! -d \$(MANPATH)/cat1 ; \\" >> Makefile
${ECHO} "	then \\" >> Makefile
${ECHO} "		\$(MKDIR) -p \$(MANPATH)/cat1 ; \\" >> Makefile
${ECHO} "	fi" >> Makefile
${ECHO} "	# cp necessary files to INSTALLDIR" >> Makefile
${ECHO} "	\$(CP) -f \$(PRODUCTION_FILES) \$(INSTALLDIR)" >> Makefile
${ECHO} "	cd \$(INSTALLDIR) ; \$(CHMOD) 755 \$(EXECUTABLE_FILES)" >> Makefile
${ECHO} "	cd \$(INSTALLDIR) ; \$(CHMOD) 644 \$(POLICY_FILES) \$(TESTJOB_FILES)" >> Makefile
${ECHO} "        # chmod necessary INSTALLDIR/ directories and files" >> Makefile
${ECHO} "        # chown necessary INSTALLDIR/ directories and files" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERBINDWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERBINDWRAP)" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERUNBINDWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERUNBINDWRAP)" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERBINDJOBWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERBINDJOBWRAP)" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERUNBINDJOBWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERUNBINDJOBWRAP)" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERCANCELWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERCANCELWRAP)" >> Makefile
${ECHO} "	- \$(CHOWN) \$(CATUSEROWNER):\$(CATUSERGROUP) \$(INSTALLDIR)/\$(USERSETWRAP)" >> Makefile
${ECHO} "	\$(CHMOD) \$(CATUSERPERMS) \$(INSTALLDIR)/\$(USERSETWRAP)" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "test:" >> Makefile
${ECHO} "	- \$(INSTALLDIR)/\$(TESTRES)" >> Makefile
${ECHO} "" >> Makefile
if [ "${CATALINA_BUILDMODE}" != "SIM" ]; then
	${ECHO} "\$(QJ): \$(QJ).c" >> Makefile
	${ECHO} "	\$(CC) \$(RMCFLAGS) -o \$@ \$(QJ).c \$(RMLIBS)" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(QJ).c: \$(QJ).c.dist" >> Makefile
	${ECHO} "	\$(CAT) \$@.dist > \$@" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(QM): \$(QM).c" >> Makefile
	${ECHO} "	\$(CC) \$(RMCFLAGS) -o \$@ \$(QM).c \$(RMLIBS)" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(QM).c: \$(QM).c.dist" >> Makefile
	${ECHO} "	\$(CAT) \$@.dist > \$@" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(RUNJOB): \$(RUNJOB).c" >> Makefile
	${ECHO} "	\$(CC) \$(RMCFLAGS) -o \$@ \$(RUNJOB).c \$(RMLIBS)" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(RUNJOB).c: \$(RUNJOB).c.dist" >> Makefile
	${ECHO} "	\$(CAT) \$@.dist > \$@" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(PREEMPTJOB): \$(PREEMPTJOB).c" >> Makefile
	${ECHO} "	\$(CC) \$(RMCFLAGS) -o \$@ \$(PREEMPTJOB).c \$(RMLIBS)" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(PREEMPTJOB).c: \$(PREEMPTJOB).c.dist" >> Makefile
	${ECHO} "	\$(CAT) \$@.dist > \$@" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(RESUMEJOB): \$(RESUMEJOB).c" >> Makefile
	${ECHO} "	\$(CC) \$(RMCFLAGS) -o \$@ \$(RESUMEJOB).c \$(RMLIBS)" >> Makefile
	${ECHO} "" >> Makefile
	${ECHO} "\$(RESUMEJOB).c: \$(RESUMEJOB).c.dist" >> Makefile
	${ECHO} "	\$(CAT) \$@.dist > \$@" >> Makefile
	${ECHO} "" >> Makefile
fi
${ECHO} "\$(USERBINDWRAP): \$(USERBINDWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERBINDWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERBINDWRAP).c: \$(USERBINDWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_BIND_RES_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERBINDPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERUNBINDWRAP): \$(USERUNBINDWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERUNBINDWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERUNBINDWRAP).c: \$(USERUNBINDWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_UNBIND_RES_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERUNBINDPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERBINDJOBWRAP): \$(USERBINDJOBWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERBINDJOBWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERBINDJOBWRAP).c: \$(USERBINDJOBWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_BIND_JOB_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERBINDJOBPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERUNBINDJOBWRAP): \$(USERUNBINDJOBWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERUNBINDJOBWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERUNBINDJOBWRAP).c: \$(USERUNBINDJOBWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_UNBIND_JOB_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERUNBINDJOBPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "# There\'s a problem with signal handling here" >> Makefile
${ECHO} "\$(USERCANCELWRAP): \$(USERCANCELWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERCANCELWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERCANCELWRAP).c: \$(USERCANCELWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_CANCEL_RES_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERCANCELPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "#\$(USERCANCELWRAP).o: \$(USERCANCELWRAP).c" >> Makefile
${ECHO} "#	\$(CC) -c \$(CATUSERCFLAGS) \$(USERCANCELWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERSETWRAP): \$(USERSETWRAP).c" >> Makefile
${ECHO} "	\$(CC) \$(CATUSERCFLAGS) -o \$@ \$(USERSETWRAP).c" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "\$(USERSETWRAP).c: \$(USERSETWRAP).c.dist" >> Makefile
${ECHO} "	\$(CAT) \$@.dist | \$(SED) 's@___USER_SET_RES_PLACEHOLDER___@\$(INSTALLDIR)/\$(USERSETPY)@g' > \$@" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "#\$(USERSETWRAP).o: \$(USERSETWRAP).c" >> Makefile
${ECHO} "#	\$(CC) -c \$(CATUSERCFLAGS) \$(USERSETWRAP).c" >> Makefile
${ECHO} "" >> Makefile

${ECHO} "MACH_SPECIFIC:" >> Makefile
${ECHO} "	\$(CP) -f \$(SHOWBF).\$(CLUSTER_NAME).dist \$(SHOWBF).dist" >> Makefile
${ECHO} "	\$(CP) -f \$(SHOWBFALL).\$(CLUSTER_NAME).dist \$(SHOWBFALL).dist" >> Makefile

${ECHO} "TESTJOBS: " >> Makefile
${ECHO} "	for i in \$(TESTJOB_FILES) ; do \\" >> Makefile
${ECHO} "		\$(CAT) \$\$i.dist | \\" >> Makefile
${ECHO} "		\$(SED) 's@___DEFAULT_JOB_CLASS_PLACEHOLDER___@${DEFAULT_JOB_CLASS}@g' | \\" >> Makefile
${ECHO} "		\$(SED) 's@___DEFAULT_JOB_QOS_PLACEHOLDER___@${DEFAULT_JOB_QOS}@g' | \\" >> Makefile
${ECHO} "		\$(SED) 's@___TESTACCOUNT_PLACEHOLDER___@${CATALINA_TESTACCOUNT-${TESTACCOUNT}}@g' \\" >> Makefile
${ECHO} "		> \$\$i ; \\" >> Makefile
${ECHO} "	done" >> Makefile

${ECHO} "PYSUB: " >> Makefile
${ECHO} "	for i in \$(PY_EXECUTABLE_FILES) \$(CATALINA) \$(CATALINA_RM) ; do \\" >> Makefile
${ECHO} "		\$(CAT) \$\$i.dist | \\" >> Makefile
${ECHO} "		\$(SED) -f sedscrb \\">> Makefile
${ECHO} "		> \$\$i ; \\" >> Makefile
${ECHO} "	done" >> Makefile

${ECHO} "" >> Makefile
${ECHO} "KSHSUB:" >> Makefile
${ECHO} "	for i in \$(KSH_EXECUTABLE_FILES) ; do \\" >> Makefile
${ECHO} "		\$(CAT) \$\$i.dist  \\" >> Makefile
${ECHO} "		| \$(SED) 's@___KSH_PATH_PLACEHOLDER___@\$(KSHPATH)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___PS_PLACEHOLDER___@\$(PS)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___PSOPTIONS_PLACEHOLDER___@\$(PSOPTIONS)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___GREP_PLACEHOLDER___@\$(GREP)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___WC_PLACEHOLDER___@\$(WC)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___AWK_PLACEHOLDER___@\$(AWK)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___DATE_PLACEHOLDER___@\$(DATE)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___HOMEDIR_PLACEHOLDER___@\$(INSTALLDIR)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___NOHUP_PLACEHOLDER___@\$(NOHUP)@g' \\">> Makefile
${ECHO} "		| \$(SED) 's@___SLEEP_PLACEHOLDER___@\$(SLEEP)@g' \\">> Makefile
${ECHO} "		> \$\$i ; \\" >> Makefile
${ECHO} "	done" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "clean:" >> Makefile
${ECHO} "	\$(RM) -f *.c *.o *.py" >> Makefile
${ECHO} "	for i in \$(PY_EXECUTABLE_FILES) \$(CATALINA) \$(CATALINA_RM) ; do \\" >> Makefile
${ECHO} "		if test -x \$\$i ; \\" >> Makefile
${ECHO} "		then \\" >> Makefile
${ECHO} "		\$(RM) \$\$i ; \\" >> Makefile
${ECHO} "		fi ; \\" >> Makefile
${ECHO} "	done" >> Makefile
${ECHO} "" >> Makefile
${ECHO} "config:" >> Makefile
${ECHO} "	\$(CHMOD) u+w catalina.config" >> Makefile
${ECHO} "	\$(CAT) catalina.config.dist \\" >> Makefile
${ECHO} "	| \$(SED) -f sedscr \\">> Makefile
${ECHO} "	> catalina.config" >> Makefile
