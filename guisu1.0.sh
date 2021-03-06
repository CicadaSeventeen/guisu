#!/usr/bin/env bash
VERSION=1.0-beta
GUISUHOME=https://github.com/djypku/guisu

trap 'onCtrlC' INT
function onCtrlC () {
    echo $$
    [ -e $XDG_RUNTIME_DIR/guisu/$$ ] && rm -rf $XDG_RUNTIME_DIR/guisu/$$
    exit 3
}

function runsu(){
    PID=$$
    PWD=`pwd`
    RUNPATH=$XDG_RUNTIME_DIR/guisu/$PID
    FIFOPATH=$RUNPATH/fifo
    BASHPATH=$RUNPATH/$COMMAND_NAME
    [ -d $XDG_RUNTIME_DIR/guisu ] || mkdir -p $XDG_RUNTIME_DIR/guisu
    if [ -e $RUNPATH ]
    then
        rm -rf $RUNPATH
    fi
    mkdir -p $RUNPATH
    mkfifo $FIFOPATH
    touch $BASHPATH
    echo '#!/usr/bin/env bash'>>$BASHPATH
    echo "source $FIFOPATH">>$BASHPATH
    echo "cd $PWD">>$BASHPATH
    echo "$COMMAND">>$BASHPATH
    echo 'exit 0'>>$BASHPATH
    chmod 755 $BASHPATH
    export > "$FIFOPATH" &
    pkexec $PARA $BASHPATH
    rm -rf $RUNPATH
}

function showhelp(){
    echo "usage:"
    echo
    echo "guisu --version (-v)  |"
    echo "      --help    (-h)  |"
    echo "      [--user (-u) username] [PROGRAM] [ARGUMENTS...]"
    echo
    echo "Default user is root"
    echo
    echo "guisu based on pkexec (polkit)"
    echo "polkit home page: <http://www.freedesktop.org/wiki/Software/polkit>"
    echo "guisu home page: <$GUISUHOME>"
    exit 2
}

function showversion(){
    echo "guisu version $VERSION"
    pkexec --version
    exit 1
}

COMMAND=$*
COMMAND_NAME=$1
[ ! $1 ] && showhelp
case $1 in
    --version | -v)
    showversion
    ;;
    --help | -h)
    showhelp
    ;;
    --user | -u)
    [ ! $2 ] && showhelp
    [ ! $3 ] && showhelp
    PARA="--user $2"
    COMMAND_NAME=$3
    COMMAND=${COMMAND#*' '}
    COMMAND=${COMMAND#*' '}
    ;;
    *)
    PARA=''
    COMMAND_NAME=$1
    ;;
esac
runsu
exit 0

