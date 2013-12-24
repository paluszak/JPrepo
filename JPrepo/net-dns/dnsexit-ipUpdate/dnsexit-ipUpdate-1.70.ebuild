# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils systemd readme.gentoo

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
	Configuration can be done manually via ${EROOT}/usr/sbin/dnsexit-setup or
	by using this ebuild's config option."

src_prepare() {
	sed -i -e "s:/etc/dnsexit.conf:${EROOT}/etc/dnsexit.conf:" ipUpdate.pl
	sed -i -e "s:/etc/dnsexit.conf:${EROOT}/etc/dnsexit.conf:" setup.pl
}

src_install() {
	LIBEXECDIR="${EROOT}"/usr/libexec/dnsexit-ipUpdate
	sed -e "s:LIBEXECDIR:${LIBEXECDIR}" "${FILESDIR}"/dnsexit-setup > "${T}"/dnsexit-setup || die "sed failed"
	sed -e "s:LIBEXECDIR:${LIBEXECDIR}" "${FILESDIR}"/dnsexit-ipUpdate > "${T}"/dnsexit-ipUpdate || die "sed failed"
	sed -e "s:EROOT:${EROOT}:" "${FILESDIR}"/dnsexit-ipUpdate.service > "${T}"/dnsexit-ipUpdate.service || die "sed failed"
	sed -e "s:EROOT:${EROOT}:" "${FILESDIR}"/dnsexit-ipUpdate.init.d > "${T}"/dnsexit-ipUpdate.init.d || die "sed failed"
	dosbin "${T}"/dnsexit-setup "${T}"/dnsexit-ipUpdate
	insinto "${LIBEXECDIR}"
	doins Http_get.pm setup.pl ipUpdate.pl
	dodoc doc/README.txt doc/Changelog
	newinitd "${T}"/dnsexit-ipUpdate.init.d dnsexit-ipUpdate
	systemd_dounit "${FILESDIR}"/dnsexit-ipUpdate.service
	readme.gentoo_create_doc
}

pkg_config() {
	cd /tmp
	einfo "Answer the following questions."
	dnsexit-setup || die
}
