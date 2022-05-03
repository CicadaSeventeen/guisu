#!/usr/bin/env bash
trap 'onCtrlC' INT
function onCtrlC () {
    echo "Stopping"
    rm $XDG_RUNTIME_DIR/guisu:$PID
    rm $XDG_RUNTIME_DIR/guisu-$COMMAND_NAME:$PID
    echo "Temfs cleared"
}

PID=$$
COMMAND_NAME=$1
echo PID:" "$PID
if [ -e $XDG_RUNTIME_DIR/guisu:$PID ]
then
    echo "Same PID found"
    rm $XDG_RUNTIME_DIR/guisu:$PID
fi
echo "Making fifo"
mkfifo $XDG_RUNTIME_DIR/guisu:$PID
echo "Fifo maken"
echo "Making guisu shell of $COMMAND_NAME"
echo '#!/usr/bin/env bash'>$XDG_RUNTIME_DIR/guisu-$1:$PID
echo "pkexec bash -c \"source $XDG_RUNTIME_DIR/guisu:$PID;$*\"">>$XDG_RUNTIME_DIR/guisu-$1:$PID
echo 'exit 0'>>$XDG_RUNTIME_DIR/guisu-$1:$PID
chmod 755 $XDG_RUNTIME_DIR/guisu-$1:$PID
echo "Guisu shell of $COMMAND_NAME maken"
echo "Piping env"
export > $XDG_RUNTIME_DIR/guisu:$PID&
echo "Pkexec running"
pkexec $XDG_RUNTIME_DIR/guisu-$1:$PID
echo "Pkexec run finnished"
rm $XDG_RUNTIME_DIR/guisu:$PID
rm $XDG_RUNTIME_DIR/guisu-$COMMAND_NAME:$PID
echo "Temfs cleared"
exit 0
