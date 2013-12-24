# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils systemd

MY_P=ipUpdate-${PV}
DESCRIPTION="dnsexit.com dynamic DNS updater"
HOMEPAGE="http://www.dnsexit.com"
SRC_URI="http://downloads.dnsexit.com/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/perl"
DEPEND=""

S=${WORKDIR}/dnsexit

DOC_CONTENTS="
	Configuration can be done manually via /usr/sbin/setup-DNSEXIT or
	by using this ebuild's config option.
"

src_prepare() {
#	epatch "${FILESDIR}"/noip-2.1.9-flags.patch
#	epatch "${FILESDIR}"/noip-2.1.9-daemon.patch
#	sed -i \
#		-e "s:\(#define CONFIG_FILEPATH\).*:\1 \"/etc\":" \
#		-e "s:\(#define CONFIG_FILENAME\).*:\1 \"/etc/no-ip2.conf\":" \
#		noip2.c || die "sed failed"
	sed -i -e "s/ipUpdate.pl/ipUpdate-DNSEXIT/" init/ipUpdate-DNSEXIT.service
}

#src_compile() {
#	emake \
#		CC=$(tc-getCC) \
#		PREFIX=/usr \
#		CONFDIR=/etc
#}

src_install() {
	LIBEXECDIR=/usr/libexec/ipUpdater-DNSEXIT
	#dodir /usr/libexec/ipUpdater-DNSEXIT
	echo "perl -l ${LIBEXECDIR} ${LIBEXECDIR}/setup.pl" > ${T}/setup-DNSEXIT
	echo "perl -l ${LIBEXECDIR} ${LIBEXECDIR}/ipUpdate.pl" > ${T}/ipUpdate-DNSEXIT
	dosbin ${T}/setup-DNSEXIT ${T}/ipUpdate-DNSEXIT
	insinto ${LIBEXECDIR}
	doins Http_get.pm setup.pl ipUpdate.pl
#	exeinto ${LIBEXECDIR}
#	doexe setup.pl ipUpdate.pl
	dodoc doc/README.txt doc/Changelog
	#newinitd init/ipUpdate-DNSEXIT.service ipUpdate-DNSEXIT
	systemd_dounit init/ipUpdate-DNSEXIT.service
#	readme.gentoo_create_doc
}

pkg_config() {
	cd /tmp
	einfo "Answer the following questions."
	setup-DNSEXIT || die
}
