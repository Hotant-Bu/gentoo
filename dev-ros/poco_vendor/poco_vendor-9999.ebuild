# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..10} )

inherit cmake python-any-r1

if [ "${PV#9999}" != "${PV}" ] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ros2/poco_vendor"
else
	SRC_URI="https://github.com/ros2/poco_vendor/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="CMake shim over the poco library"
HOMEPAGE="https://github.com/ros2/poco_vendor"

LICENSE="Apache-2.0 Boost-1.0"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/poco-1.6.1
	dev-libs/libpcre
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="
	$(python_gen_any_dep 'ros-meta/ament_cmake[${PYTHON_USEDEP}]')
	test? (
		dev-ros/ament_cmake_copyright
		dev-ros/ament_cmake_lint_cmake
		dev-ros/ament_cmake_xmllint
		dev-ros/ament_cmake_test
	)
	${PYTHON_DEPS}
"

python_check_deps() {
	python_has_version "ros-meta/ament_cmake[${PYTHON_USEDEP}]"
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}
