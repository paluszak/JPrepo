#!/sbin/runscript

depend() {
	need localmount
	need net
	use dns
}

checkconfig() {
	if [ ! -f EROOT/etc/dnsexit.conf ]
	then
		einfo "Answer the following questions about your dnsexit account."
		dnsexit-setup || return 1
	fi
	
}

start() {
	checkconfig || return 1
	ebegin "Starting dnsexit-ipUpdate"
	start-stop-daemon --quiet --start -x EROOT/usr/sbin/ipUpdate
	eend $? "dnsexit-ipUpdate did not start, error code $?"
}

stop() {
	ebegin "Stopping dnsexit-ipUpdate"
	start-stop-daemon --quiet --stop -x EROOT/usr/sbin/dnsexit-ipUpdate
	noip_ecode=$?
	eend $noip_ecode "Error stopping the dnsexit-ipUpdate daemon, error $noip_ecode"
	checkconfig || return 1
#	ebegin "Setting noip addresses to 0.0.0.0"
#	noip2 -c /etc/no-ip2.conf -i 0.0.0.0 >& /dev/null
#	eend $? "Failed to set noip addresses to 0.0.0.0, error $?"
	return $noip_ecode
}
