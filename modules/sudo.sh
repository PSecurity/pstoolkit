
sudo_mode() {

SYSBIN=/system/bin
SYSXBIN=/system/xbin
PRE=/data/data/com.termux/files
ROOT_HOME=$PRE/home/.suroot
BINPRE=$PRE/usr/bin
LDLP="export LD_LIBRARY_PATH=$PRE/usr/lib"
CMDLINE="PATH=$PATH:$SYSXBIN:$SYSBIN;$LDLP;HOME=$ROOT_HOME;cd $PWD"

if [ -x /magisk/.core/bin/su ]; then
	SU=/magisk/.core/bin/su
elif [ -x /sbin/su ]; then
	SU=/sbin/su
elif [ -x $SYSXBIN/su ]; then
	SU=$SYSXBIN/su
elif [ -x /su/bin/su ]; then
	SU=/su/bin/su
else
	echo "❌ su não encontrado"
	return
fi

$SU -c "$CMDLINE;$BINPRE/bash"
}
