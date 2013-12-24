#!/sbin/runscript

PIDFILE=`grep pidfile EROOTetc/dnsexit.conf | sed -e 's:pidfile=::'`

depend() {
	need localmount
	need net
	use dns
}

checkconfig() {
	if [ ! -f EROOTetc/dnsexit.conf ]
	then
		einfo "Answer the following questions about your dnsexit account."
		dnsexit-setup || return 1
	fi
	
}

start() {
	checkconfig || return 1
	ebegin "Starting dnsexit-ipUpdate"
	start-stop-daemon --quiet --start --pidfile "${PIDFILE}" -x EROOTusr/sbin/dnsexit-ipUpdate
	eend $? "dnsexit-ipUpdate did not start, error code $?"
}

stop() {
	ebegin "Stopping dnsexit-ipUpdate"
	start-stop-daemon --quiet --stop --pidfile "${PIDFILE}"
	ipUpdate_ecode=$?
	eend $ipUpdate_ecode "Error stopping the dnsexit-ipUpdate daemon, error $ipUpdate_ecode"
	checkconfig || return 1
	return $ipUpdate_ecode
}
