# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..10} )

inherit python-any-r1 scons-utils toolchain-funcs

MY_PN="${PN}-4"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Synchronous multi-master replication engine that provides the wsrep API"
HOMEPAGE="https://galeracluster.com"
SRC_URI="https://releases.galeracluster.com/${MY_PN}/source/${MY_P}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2 BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86"
IUSE="cpu_flags_x86_sse4_2 garbd test"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/openssl:0=
	>=dev-libs/boost-1.41:0=
"

DEPEND="
	${COMMON_DEPEND}
	dev-libs/check
	>=dev-cpp/asio-1.22
"

#Run time only
RDEPEND="${COMMON_DEPEND}"

# Respect {C,LD}FLAGS.
PATCHES=(
	"${FILESDIR}/${PN}"-26.4.6-strip-extra-cflags.patch
	"${FILESDIR}/${PN}"-26.4.8-respect-toolchain.patch
	"${FILESDIR}/${PN}"-26.4.13-asio.patch
	"${FILESDIR}/${PN}"-26.4.13-tests.patch
)

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default
	# Remove bundled dev-cpp/asio
	rm -r "${S}/asio" || die "Failed to remove bundled asio"
	#Remove optional garbd daemon
	if ! use garbd ; then
		rm -r "${S}/garb" || die "Failed to remove garbd daemon"
	fi
}

src_configure() {
	tc-export AR CC CXX OBJDUMP
	# strict_build_flags=0 disables -Werror, -pedantic, -Weffc++,
	# and -Wold-style-cast
	MYSCONS=(
		crc32c_no_hardware=$(usex cpu_flags_x86_sse4_2 0 1)
		tests=$(usex test 1 0)
		strict_build_flags=0
		system_asio=1
	)
}

src_compile() {
	escons --warn=no-missing-sconscript "${MYSCONS[@]}"
}

src_install() {
	dodoc scripts/packages/README scripts/packages/README-MySQL
	if use garbd ; then
		dobin garb/garbd
		newconfd "${FILESDIR}/garb.cnf" garbd
		newinitd "${FILESDIR}/garb.init" garbd
		doman man/garbd.8
	fi
	exeinto /usr/$(get_libdir)/"${PN}"
	doexe libgalera_smm.so
}
