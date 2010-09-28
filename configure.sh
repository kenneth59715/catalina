#! /bin/ksh
# Catalina install script to be run on DataStar node ds002 or TG
# written by Eva Hocks 03/22/2006

#


if [ $# != 0 ] ; then
   echo "\n Usage parameters: ./configure.sh"
   exit
fi 

#added by Martin Margo 6/5/2006
echo "Welcome to Catalina interactive configuration utility"
echo " ----------------------------------------------------"

echo "Saving original stty settings...."
#Save user original stty settings
USER_ORIGINAL_STTY=`stty -g` 
export USER_ORIGINAL_STTY
#set the backspace character ^? to stty erase
stty erase ^?

#### setting environment

echo "Setting environment variables..."
while [[ $RESOURCEMANAGER != LL && $RESOURCEMANAGER != PBS && $RESOURCEMANAGER != TORQUE && $RESOURCEMANAGER != SLURM ]]; do
echo "\n  Enter resource manager (LL|PBS|TORQUE|SLURM) \c"
read RESOURCEMANAGER
case $RESOURCEMANAGER in
   LL*) ;;
   PBS*) ;;
   TORQUE*) ;;
   SLURM*) ;;
   *) echo "either LL, PBS, TORQUE or SLURM required ";;
esac
done
export RESOURCEMANAGER

#echo "\n  Enter Cluster name (DS|TG) \c"
#read CLUSTER_NAME
#case $CLUSTER_NAME in
#	DS*) ;;
#	TG*) ;;
#	*) echo " warning : recognizable cluster name are TG or DS";;
#esac
#export CLUSTER_NAME

echo "\n  Enter $RESOURCEMANAGER lib dirs (e.g. /opt/torque/lib) \c"
read CATALINA_RMLIBDIRS
CATALINA_RMLIBDIRS="-L$CATALINA_RMLIBDIRS"
export  CATALINA_RMLIBDIRS

echo "\n  Enter $RESOURCEMANAGER include dir (e.g. /opt/torque/include) \c"
read CATALINA_RMINCDIRS
CATALINA_RMINCDIRS="-I$CATALINA_RMINCDIRS"
export CATALINA_RMINCDIRS


# If LL, location of LoadLeveler admin file
# If PBS, name of host from which jobs will be submitted and reservations set
# if desired, this can be set to IGNORE

if [ $RESOURCEMANAGER = "LL" ] ; then
 echo "\n  Enter LoadLeveler Admin file (e.g. /users/loadl/LoadL_admin.Datastar ) \c"
 read CATALINA_LOADL_ADMIN_FILE
 export CATALINA_LOADL_ADMIN_FILE
else
 echo "\nSetting CATALINA_PBS_SUBMITHOST=IGNORE"
 export  CATALINA_PBS_SUBMITHOST=IGNORE
fi

echo "\n  Enter catalina owner (e.g. loadl) \c"
read CATALINA_CATOWNER
if [ -z "$CATALINA_CATOWNER" ]; then
 CATALINA_CATOWNER=loadl
fi
export CATALINA_CATOWNER

echo "\n  Enter e-mail recipient (e.g. loadl@sdsc.edu) \c"
read CATALINA_MAIL_RECIPIENT
if [ -z "$CATALINA_MAIL_RECIPIENT" ] ; then
  CATALINA_MAIL_RECIPIENT=loadl
fi
export CATALINA_MAIL_RECIPIENT



echo "\n  Enter catalina group (e.g. catalina) \c"
read CATALINA_CATLOCKGROUP
if [ -z "$CATALINA_CATLOCKGROUP" ]; then
 CATALINA_CATLOCKGROUP=catalina
fi
export CATALINA_CATLOCKGROUP

echo "\n  Enter MAN directory : \c"
read CATALINA_MANPATH
export CATALINA_MANPATH

echo "\n  Enter install directory : \c"
read CATALINA_INSTALLDIR
export CATALINA_INSTALLDIR

echo "\n  Enter Database directory : \c" 
read CATALINA_DBDIR
export CATALINA_DBDIR

echo "\n  Enter archived logs directory : \c"
read CATALINA_ARCHIVEDIR
export CATALINA_ARCHIVEDIR

echo "\n  Enter C compiler (e.g /usr/local/bin/gcc) \c"
read CC
if [ -z "$CC" ]; then
 CC=/usr/local/bin/gcc
fi
export CC 

echo "\n  Enter Python 2.4 or greater interpreter (e.g. /usr/local/apps/python/bin/python) \c"
read CATALINA_PYTHONPATH
if [ -z "$CATALINA_PYTHONPATH" ]; then
 CATALINA_PYTHONPATH=/usr/bin/python
fi
export CATALINA_PYTHONPATH

echo "\n  Enter permissions for user-settable reservation commands (e.g. 2755) \c"
read CATALINA_CATUSERPERMS
export CATALINA_CATUSERPERMS 


echo "\n  Enter default job class or queue  (e.g normal, standard, dque) \c"
read CATALINA_DEFAULT_JOB_CLASS
export CATALINA_DEFAULT_JOB_CLASS

################
echo "export CLUSTER_NAME=$CLUSTER_NAME" > ./settings.sh
echo "export RESOURCEMANAGER=$RESOURCEMANAGER" >> ./settings.sh 
echo "export CATALINA_RMLIBDIRS=$CATALINA_RMLIBDIRS" >> ./settings.sh
echo "export CATALINA_RMINCDIRS=$CATALINA_RMINCDIRS" >> ./settings.sh
echo "export CATALINA_CATOWNER=$CATALINA_CATOWNER" >> ./settings.sh
echo "export CATALINA_MAIL_RECIPIENT=$CATALINA_MAIL_RECIPIENT" >> ./settings.sh
echo "export CATALINA_CATLOCKGROUP=$CATALINA_CATLOCKGROUP" >> ./settings.sh
echo "export CATALINA_MANPATH=$CATALINA_MANPATH" >> ./settings.sh
echo "export CATALINA_INSTALLDIR=$CATALINA_INSTALLDIR" >> ./settings.sh
echo "export CATALINA_DBDIR=$CATALINA_DBDIR" >> ./settings.sh
echo "export CATALINA_ARCHIVEDIR=$CATALINA_ARCHIVEDIR" >> ./settings.sh
echo "export CC=$CC" >> ./settings.sh
echo "export CATALINA_PYTHONPATH=$CATALINA_PYTHONPATH" >> ./settings.sh
echo "export CATALINA_CATUSERPERMS=$CATALINA_CATUSERPERMS" >> ./settings.sh
echo "export CATALINA_DEFAULT_JOB_CLASS=$CATALINA_DEFAULT_JOB_CLASS" >> ./settings.sh
echo "export CATALINA_LOADL_ADMIN_FILE=$CATALINA_LOADL_ADMIN_FILE" >> ./settings.sh
echo "export CATALINA_PBS_SUBMITHOST=$CATALINA_PBS_SUBMITHOST" >> ./settings.sh
echo "========="
echo "This is the current settings:"
cat ./settings.sh 
echo "=========="
echo "\n  Do you want to proceed? (yes|no) \c"
read response
  case $response in
   no) stty $USER_ORIGINAL_STTY ; exit 3;;
   yes);;
   *) echo "enter yes or no"; stty $USER_ORIGINAL_STTY ; exit 14;;
  esac
## I want to give options to save the settings to a file so that people can rerun the installation without going to step 1 again
echo "\n  Do you want to save this configuration settings to a file?"
echo "  Saving this configuration settings mean that you can skip the"
echo "  interactive session if the installation fail for any reason."
echo "  Recommended. (yes|no) \c"
read response
  case $response in 
   no) /bin/rm settings.sh;;
   yes) echo "Done. The setting is in settings.sh. Source this file " ; echo " by using . ./settings.sh ; make install (if the installation fails during make install";;
   *) echo "enter yes or no"; stty $USER_ORIGINAL_STTY; exit 14;;
  esac
  

#### Now that all the variables are set. We can call conf.sh ####


#### Get conf.sh to work
./conf.sh

echo "\n Do you want to run \"make\" ? (yes|no) \c"
read response
	case $response in
	 no) stty $USER_ORIGINAL_STTY; exit 3;;
	 yes);;
	 *) echo " enter yes or no"; stty $USER_ORIGINAL_STTY ; exit 14;;
	esac

#
#make
#
make


echo "\n  Do you want to proceed to run \"make install\" ? (yes|no) \c"
read response
   case $response in
    no) stty $USER_ORIGINAL_STTY ; exit 3;;
    yes);;
    *) echo " enter yes or no"; stty $USER_ORIGINAL_STTY ; exit 14;;
   esac
# 
# make install
# 
# #
make install

echo "\n  Do you want to proceed to run \"make config\" ? (yes|no) \c"
read response
   case $response in
    no) echo "\nYou have to copy previous installation's catalina.config to the new install dir. Make sure that the config points to the correct absolute paths."; stty $USER_ORIGINAL_STTY ; exit 0;;
    yes);;
    *) echo " enter yes or no" ; stty $USER_ORIGINAL_STTY ; exit 14;; 
   esac

make config
#the above command will produce catalina.config file which should be copied over to $CATALINA_INSTALLDIR
echo "Compare catalina.config to $CATALINA_INSTALLDIR/catalina.config and revise"

stty $USER_ORIGINAL_STTY 
exit 0
