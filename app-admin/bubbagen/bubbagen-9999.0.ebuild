# Copyright 2015-2016 gordonb3 <gordon@bosvangennip.nl>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"

inherit eutils git-r3

EGIT_REPO_URI="https://github.com/gordonb3/${PN}.git"

DESCRIPTION="The Bubba main package"
HOMEPAGE="https://github.com/gordonb3/bubbagen"
KEYWORDS=""
VMAJOR=${PV:0:4}
REVISION=$((${PV:5}%5))
#SRC_URI="https://github.com/gordonb3/bubbagen/archive/v${VMAJOR}.tar.gz -> ${PF}.tgz"
LICENSE="GPL-3+"
SLOT="0/${VMAJOR}"
IUSE="bindist"
RESTRICT="mirror"

# Conflicts/replaces Sakaki's b3-init-scripts
DEPEND="
	!sys-apps/b3-init-scripts
	>=virtual/udev-215
	>=sys-apps/ethtool-3.12.1
	!virtual/bubba:0/0
"

RDEPEND="${DEPEND}
	app-admin/bubba-frontend
	app-admin/bubba-manual
	arm? ( sys-power/bubba-buttond )
"

REMOVELIST=""
IS_BINDIST=""
KERNEL_MAJOR=""
KERNEL_MINOR=""

pkg_setup() {
	[[ -e /var/lib/bubba/bubba-default-config.tgz ]] || return

	# find unaltered portage config files from a previous bubbagen release
	mkdir -p ${WORKDIR}/oldconfig
	cd ${WORKDIR}/oldconfig
	tar -xzf /var/lib/bubba/bubba-default-config.tgz
	find etc/portage -type f | while read FILE; do
		if ( ! diff -q ${FILE} /${FILE} 2&> /dev/null ); then
			# file has been altered from default
			rm -f ${FILE}
		fi
	done
	cd - > /dev/null

	# determine what bindist state our current system is in
	IS_BINDIST=$(equery u dev-libs/openssl | grep bindist)

	# get kernel version
	KERNEL_MAJOR=$(uname -r | cut -d. -f1)
	KERNEL_MINOR=$(uname -r | cut -d. -f2)
}

src_prepare() {
	# Git does not support empty folders
	# clean up the bogus content here.
	find ${S} -name ~nofiles~ -exec rm {} \;

	# revision 5 and higher: combine systemd specific files with the regular openrc tree
	[[ ${PV:5} -gt 4 ]] && cp -a ${S}/systemd/* ${S}/

	# if enabled, include config files required to prevent bindist conflicts
	use bindist && [[ -d ${S}/bindist ]] && cp -a ${S}/bindist/* ${S}/

	# correct for different settings between B2 and B3
	use ppc && rm etc/portage/package.use/sysvinit

	# remove xtables-addons 3.x mask when kernel >= 4.15
	XT_ADDONS="/etc/portage/package.mask/xtables-addons"
	[[ ${KERNEL_MAJOR} -gt 4 ]] && REMOVELIST="${XT_ADDONS}" && rm -f ${S}${XT_ADDONS}
	[[ ${KERNEL_MAJOR} -eq 4 ]] && [[ ${KERNEL_MINOR} -gt 14 ]] && REMOVELIST="${XT_ADDONS}" && rm -f ${S}${XT_ADDONS}
}

src_compile() {
	[[ -d ${WORKDIR}/oldconfig ]] || return

	# build list of portage config files that need to be removed
	cd ${WORKDIR}/oldconfig
	find etc/portage -type f | while read FILE; do
		[[ -e ${S}/${FILE} ]] || REMOVELIST="${REMOVELIST} /${FILE}"
	done
	cd - > /dev/null

	elog "Create bubba-default-config archive"
	tar -czf bubba-default-config.tgz etc
}

src_install() {
        dodir /etc/bubba
	echo ${PV} > ${ED}/etc/bubba/bubba.version

	insinto /var/lib/bubba
	doins bubba-default-config.tgz

	elog "Installing portage config files"
	rm etc/portage/make.conf
	insinto /etc
	cp -aR etc/portage ${ED}/etc/

	exeinto /opt/bubba/sbin
	doexe sbin/bubba-restore-defaults.sh
	fperms 750 /opt/bubba/sbin/bubba-restore-defaults.sh

	exeinto /usr/share/distcc
	doexe usr/share/distcc/distcc-fix

	if use arm; then
		elog "Add B3 udev rules"
		insinto /lib/udev/rules.d
		newins	${FILESDIR}/marvell-fix-tso.udev 50-marvell-fix-tso.rules
		newins	${FILESDIR}/net-name-use-custom.udev 70-net-name-use-custom.rules
	fi
}

pkg_postinst() {
	if [[ ! -z "${REMOVELIST}" ]]; then
		elog "Removed obsolete portage config files from previous version"
		rm -f ${REMOVELIST}
	fi

	if use bindist; then
		CONF_BINDIST=$(grep "^USE=" /etc/portage/make.conf | cut -d# -f1 | grep bindist)
		if [[ -z "${CONF_BINDIST}" ]]; then
			EMPTYUSELINE=$(grep -m1 -n "^USE=\"\"" /etc/portage/make.conf | cut -d: -f1)
			if [[ -z "${EMPTYUSELINE}" ]]; then
				sed -e "${EMPTYUSELINE} s/^USE=\"\"/USE=\"bindist\"/" -i /etc/portage/make.conf
			else
				LINENUMBER=$(grep -m1 -n "^USE=\"" /etc/portage/make.conf | cut -d: -f1)
				sed -e "${LINENUMBER} s/^USE=\"/USE=\"bindist\"\nUSE=\"\${USE} /" -i /etc/portage/make.conf
			fi
			elog "Added bindist USE flag to your global make.conf"
		fi

		# enforce overwrite of bindist conf files
		find /etc/portage/ -name ._cfg*bindist* | while read FILE; do
			CONFFILE=$(echo ${FILE} | sed "s/\._cfg[0-9]*_//")
			rm -f ${CONFFILE}
			mv ${FILE} ${CONFFILE}
		done
	else
		grep -q "^USE=\"[^#]*bindist" /etc/portage/make.conf && elog "Removed bindist USE flag from your global make.conf"
		sed -e "s/^\(USE=\"[^#]*\)bindist\(.*\)$/\1\2/" -e "s/ *\" */\"/g" -e "s/   */ /g" -i /etc/portage/make.conf

		BINDIST_CONFS=$(find /etc/portage -name *bindist*)
		[[ ! -z "${BINDIST_CONFS}" ]] && elog "Removed package specific restrictions only required for bindist"
		rm -f ${BINDIST_CONFS}
	fi

	# cleanup distcc-fix in /usr/local/sbin (not a package file in previous releases)
	[[ -e /usr/local/sbin/distcc-fix ]] && rm -f /usr/local/sbin/distcc-fix
}
