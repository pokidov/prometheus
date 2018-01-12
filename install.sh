#Installation of Prometheus on Ubuntu 14.04
sudo su
apt-get update 
useradd --no-create-home --shell /bin/false prometheus
mkdir /opt/prometheus
Download latest package from https://prometheus.io/download/
cd /opt/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz
cd prometheus-*
mv –v * /opt/prometheus
chown -R prometheus:prometheus  /opt/prometheus
nano /etc/init.d/prometheus

#!/bin/sh
	### BEGIN INIT INFO
	# Provides:          Prometheus
	# Required-Start:    $local_fs $network $named $time $syslog
	# Required-Stop:     $local_fs $network $named $time $syslog
	# Default-Start:     2 3 4 5
	# Default-Stop:      0 1 6
	# Description:       Prometheus - Monitoring system & time series database
	### END INIT INFO
	

	WORKING_DIR=/opt/prometheus
	DAEMON=$WORKING_DIR/prometheus
	NAME=prometheus
	USER=prometheus
	PIDFILE=/var/run/prometheus/$NAME.pid
	LOGFILE=/var/log/prometheus/$NAME.log
	

	ARGS=""
	

	do_start_prepare()
	{
	  mkdir -p `dirname $PIDFILE` || true
	  mkdir -p `dirname $LOGFILE` || true
	  chown -R $USER: `dirname $LOGFILE`
	  chown -R $USER: `dirname $PIDFILE`
	}
	

	do_start_cmd()
	{
	  do_start_prepare
	  echo -n "Starting daemon: "$NAME
	  start-stop-daemon --chdir $WORKING_DIR --chuid $USER -C --background --start --quiet --pidfile $PIDFILE --make-pidfile --exec $DAEMON -- $ARGS >> $LOGFILE 2>&1
	  echo "."
	}
	

	do_stop_cmd()
	{
	  echo -n "Stopping daemon: "$NAME
	  start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
	  rm $PIDFILE
	  echo "."
	}
	

	uninstall() {
	  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
	  local SURE
	  read SURE
	  if [ "$SURE" = "yes" ]; then
	    stop
	    rm -f "$PIDFILE"
	    echo "Notice: log file was not removed: '$LOGFILE'" >&2
	    update-rc.d -f <NAME> remove
	    rm -fv "$0"
	  fi
	}
	

	status() {
	  printf "%-50s" "Checking $NAME..."
	  if [ -f $PIDFILE ]; then
	    PID=$(cat $PIDFILE)
	    if [ -z "$(ps axf | grep ${PID} | grep -v grep)" ]; then
	      printf "%s\n" "The process appears to be dead but pidfile still exists"
	    else    
	      echo "Running, the PID is $PID"
	    fi
	  else
	    printf "%s\n" "Service not running"
	  fi
	}
	

	

	case "$1" in
	  start)
	    do_start_cmd
	  ;;
	  stop)
	    do_stop_cmd
	  ;;
	    status)
	    status
	  ;;
	  uninstall)
	    uninstall
	  ;;
	  restart)
	    stop
	  start
	  ;;
	  *)
	  echo "Usage: $1 {start|stop|status|restart|uninstall}"
	  exit 1
	esac
	

	exit 0

chmod 755 /etc/init.d/prometheus 
chown root:root /etc/init.d/prometheus 
update-rc.d prometheus defaults 
update-rc.d prometheus enable
service prometheus start
service prometheus status
