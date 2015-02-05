# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"

inherit eutils git-2

EGIT_REPO_URI="https://github.com/Excito/bubba-buttond.git"

DESCRIPTION="Excito B3 power control"
HOMEPAGE="http://www.excito.com/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_compile() {
	make
}


create_runscript() {
	dodir /etc/init.d
	cat > ${ED}/etc/init.d/bubba-buttond <<EOF
#!/sbin/runscript

NAME=bubba-buttond
APPROOT=/sbin
DAEMON=buttond
PIDFILE=/var/run/\${NAME}.pid

start() {
        ebegin "Starting \${NAME}"
		start-stop-daemon --start --quiet --make-pidfile --pidfile \${PIDFILE} --background --exec \${APPROOT}/\${DAEMON}
        eend \$?
}

stop() {
        ebegin "Stopping \${NAME}"
        start-stop-daemon --stop --quiet --pidfile \${PIDFILE}
        eend \$?
}
EOF
	chmod +x ${ED}/etc/init.d/bubba-buttond
}

src_install() {
	dodir /sbin
	cp -a "${S}/buttond"   ${ED}/sbin
	cp -a "${S}/write-magic"   ${ED}/sbin
	create_runscript
}
