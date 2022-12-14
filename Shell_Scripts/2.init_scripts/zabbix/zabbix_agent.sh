#!/bin/bash
#
# chkconfig: - 90 10
# description:  Starts and stops Zabbix Server using chkconfig
#                               Tested on Fedora Core 2 - 5
#                               Should work on all Fedora Core versions
#
# @name:        zabbix_server
# @author:      Alexander Hagenah <hagenah@topconcepts.com>
# @created:     18.04.2006
#
# Modified for Zabbix 2.0.0
# May 2012, Zabbix SIA
#
# Source function library.
. /etc/init.d/functions

# Variables
# Edit these to match your system settings

        # Zabbix-Directory
        BASEDIR=/usr/local/zabbix-3.2.1

        # Binary File
        BINARY_NAME=zabbix_server

        # Full Binary File Call
        FULLPATH=$BASEDIR/sbin/$BINARY_NAME

        # PID file
        PIDFILE=/tmp/$BINARY_NAME.pid

        # Establish args
        ERROR=0
        STOPPING=0

# No need to edit the things below
#

# application checking status
if [ -f $PIDFILE  ] && [ -s $PIDFILE ]
        then
        PID=`cat $PIDFILE`

        if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null && [ $BINARY_NAME == `ps -e | grep $PID | awk '{print $4}'` ]
        then
                STATUS="$BINARY_NAME (pid `pidof $APP`) running.."
                RUNNING=1
        else
                rm -f $PIDFILE
                STATUS="$BINARY_NAME (pid file existed ($PID) and now removed) not running.."
                RUNNING=0
        fi
else
        if [ `ps -e | grep $BINARY_NAME | head -1 | awk '{ print $1 }'` ]
                then
                STATUS="$BINARY_NAME (pid `pidof $APP`, but no pid file) running.."
        else
                STATUS="$BINARY_NAME (no pid file) not running"
        fi
        RUNNING=0
fi

# functions
start() {
        if [ $RUNNING -eq 1 ]
                then
                echo "$0 $ARG: $BINARY_NAME (pid $PID) already running"
        else
                #action $"Starting $BINARY_NAME: " $FULLPATH
                /usr/local/zabbix-3.2.1/sbin/zabbix_server -c /usr/local/zabbix-3.2.1/etc/zabbix_server.conf
                touch /var/lock/subsys/$BINARY_NAME
    fi
}

stop() {
        echo -n $"Shutting down $BINARY_NAME: "
        killproc $BINARY_NAME
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/$BINARY_NAME
        RUNNING=0
}


# logic
case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
        status)
                status $BINARY_NAME
                ;;
        restart)
                stop`
                sleep 10
                start
                ;;
        help|*)
        echo $"Usage: $0 {start|stop|status|restart|help}"
                cat <<EOF

                        start           - start $BINARY_NAME
                        stop            - stop $BINARY_NAME
                        status          - show current status of $BINARY_NAME
                        restart         - restart $BINARY_NAME if running by sending a SIGHUP or start if not running
                        help            - this screen

EOF
        exit 1
        ;;
esac

exit 0
