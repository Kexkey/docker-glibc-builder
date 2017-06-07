#!/usr/bin/env bash

set -eo pipefail; [[ "$TRACE" ]] && set -x

main() {
	declare version="${1:-$GLIBC_VERSION}" prefix="${2:-$PREFIX_DIR}"

	: "${version:?}" "${prefix:?}"

	{
		wget -qO- "http://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz" \
			| tar zxf -
		mkdir -p /glibc-build && cd /glibc-build
		"/glibc-$version/configure" \
			--prefix="$prefix" \
			--libdir="$prefix/lib" \
			--libexecdir="$prefix/lib" \
			--with-headers="$prefix/include" \
			--disable-multi-arch \
			--disable-werror \
			--host=armv7l-unknown-linux-gnueabihf \
			--build=armv7l-unknown-linux-gnueabihf
		install -dm755 "$prefix"/etc
		touch "$prefix"/etc/ld.so.conf
		make -j "$(getconf _NPROCESSORS_ONLN)" && make install
		tar --hard-dereference -zcf "/glibc-bin-$version.tar.gz" "$prefix"
	} >&2

	[[ $STDOUT ]] && cat "/glibc-bin-$version.tar.gz"
}

main "$@"
