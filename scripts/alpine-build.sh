#!/bin/sh

set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$repo_root/config/alpirafex.env"

build_dir="$repo_root/${ALPIRAFEX_BUILD_DIR}"
dist_dir="$repo_root/${ALPIRAFEX_DIST_DIR}"
aports_dir="$build_dir/aports"
repo_dir="$build_dir/repository"
keys_dir="$build_dir/keys"
work_dir="$build_dir/work"
builder="alpirafex"
builder_home="/home/$builder"
repo_server_pid=""

export ALPINE_BRANCH ALPINE_RELEASE ALPIRAFEX_VERSION ALPIRAFEX_REPO_BASE_URL
export REPODEST="$repo_dir"

die() {
	echo "error: $*" >&2
	exit 1
}

install_build_dependencies() {
	apk add --no-cache \
		alpine-sdk \
		abuild-rootbld \
		alpine-conf \
		atools \
		git \
		python3 \
		syslinux \
		xorriso \
		squashfs-tools \
		grub \
		mtools
}

prepare_aports() {
	mkdir -p "$build_dir"
	if [ ! -d "$aports_dir/.git" ]; then
		mkdir -p "$aports_dir"
		git -C "$aports_dir" init -q
		git -C "$aports_dir" remote add origin "$ALPINE_APORTS_URL"
	fi
	git -C "$aports_dir" fetch --depth=1 --no-tags origin "$ALPINE_APORTS_REF"
	git -C "$aports_dir" checkout --detach "$ALPINE_APORTS_REF"
	git -C "$aports_dir" rev-parse HEAD > "$build_dir/aports.ref"

	cp "$repo_root/profiles/mkimg.alpirafex.sh" "$aports_dir/scripts/"
	cp "$repo_root/profiles/genapkovl-alpirafex.sh" "$aports_dir/scripts/"
}

prepare_builder_user() {
	if ! getent group abuild >/dev/null 2>&1; then
		addgroup -S abuild
	fi
	if ! id "$builder" >/dev/null 2>&1; then
		adduser -S -D -h "$builder_home" -G abuild "$builder"
	fi
	addgroup "$builder" abuild >/dev/null 2>&1 || true
	mkdir -p "$repo_dir" "$keys_dir" "$work_dir" "$dist_dir"
	chown -R "$builder":abuild "$repo_root/packages" "$build_dir" "$dist_dir"
}

prepare_keys() {
	mkdir -p "$keys_dir"
	if [ -z "${PACKAGER_PRIVKEY:-}" ]; then
		PACKAGER_PRIVKEY="$keys_dir/alpirafex.rsa"
		if [ ! -f "$PACKAGER_PRIVKEY" ]; then
			su -s /bin/sh "$builder" -c \
				"HOME='$builder_home' abuild-keygen -a -n"
			generated_priv="$(find "$builder_home/.abuild" -type f -name '*.rsa' ! -name '*.pub' -print -quit)"
			[ -n "$generated_priv" ] || die "no generated abuild signing key found"
			cp "$generated_priv" "$PACKAGER_PRIVKEY"
			cp "$generated_priv.pub" "$PACKAGER_PRIVKEY.pub"
			chmod 600 "$PACKAGER_PRIVKEY"
		fi
	fi

	privkey="$PACKAGER_PRIVKEY"
	[ -n "$privkey" ] || die "no abuild signing key found"
	export PACKAGER_PRIVKEY="$privkey"

	pubkey="${PACKAGER_PUBKEY:-${PACKAGER_PRIVKEY}.pub}"
	[ -f "$pubkey" ] || die "public key not found: $pubkey"
	cp "$pubkey" "$keys_dir/"
	cp "$pubkey" "$keys_dir/alpirafex.rsa.pub"
	cp "$pubkey" /etc/apk/keys/
	cp "$pubkey" /etc/apk/keys/alpirafex.rsa.pub
	for key in "$keys_dir"/*.rsa.pub; do
		[ -f "$key" ] || continue
		cp "$key" /etc/apk/keys/
	done
	export ALPIRAFEX_PUBKEY_PATH="$keys_dir/alpirafex.rsa.pub"
}

configure_repositories() {
	mkdir -p "$repo_dir/packages/x86_64" "$repo_dir/packages/aarch64" "$repo_dir/packages/noarch"
	chown -R "$builder":abuild "$repo_dir"
	cat > /etc/apk/repositories <<-EOF
	$repo_dir/packages
	https://dl-cdn.alpinelinux.org/alpine/$ALPINE_BRANCH/main
	https://dl-cdn.alpinelinux.org/alpine/$ALPINE_BRANCH/community
	EOF
	apk update
}

start_repository_server() {
	python3 -m http.server 8099 --bind 127.0.0.1 --directory "$repo_dir" \
		</dev/null >/dev/null 2>&1 &
	repo_server_pid="$!"
	sleep 1
}

stop_repository_server() {
	[ -n "$repo_server_pid" ] || return 0
	kill "$repo_server_pid" 2>/dev/null || true
	repo_server_pid=""
}

index_local_repository() {
	set -- "$repo_dir/packages/x86_64"/*.apk
	[ -e "$1" ] || return 0
	cp "$repo_dir/packages/x86_64"/*.apk "$repo_dir/packages/aarch64/"
	cp "$repo_dir/packages/x86_64"/*.apk "$repo_dir/packages/noarch/"
	for arch in x86_64 aarch64 noarch; do
		apk index --description "Alpirafex $ALPIRAFEX_VERSION" \
			--output "$repo_dir/packages/$arch/APKINDEX.tar.gz" "$repo_dir/packages/$arch"/*.apk
		abuild-sign -k "$PACKAGER_PRIVKEY" "$repo_dir/packages/$arch/APKINDEX.tar.gz"
	done
}

build_one_package() {
	pkg="$1"
	printf '\n==> Building %s\n' "$pkg"
	su -s /bin/sh "$builder" -c \
		"export HOME='$builder_home' REPODEST='$repo_dir' PACKAGER_PRIVKEY='$PACKAGER_PRIVKEY'; \
		cd '$repo_root/packages/$pkg' && abuild rootbld"
	index_local_repository
}

build_packages() {
	install_build_dependencies
	prepare_aports
	prepare_builder_user
	prepare_keys
	configure_repositories
	start_repository_server

	# Build in dependency order so later meta-packages resolve from the local index.
	build_one_package alpirafex-base
	build_one_package alpirafex-suckless-tools
	build_one_package alpirafex-desktop
	build_one_package alpirafex-openssh
	build_one_package alpirafex-branding
	index_local_repository
	stop_repository_server

	mkdir -p "$dist_dir/repository/keys"
	for arch in x86_64 aarch64 noarch; do
		mkdir -p "$dist_dir/repository/$arch"
		cp "$repo_dir/packages/$arch"/*.apk "$repo_dir/packages/$arch/APKINDEX.tar.gz" \
			"$dist_dir/repository/$arch/"
	done
	cp "$keys_dir/alpirafex.rsa.pub" "$dist_dir/repository/keys/"
	printf '%s\n' "$ALPINE_APORTS_REF" > "$dist_dir/repository/aports.ref"
	printf 'Alpirafex %s\n' "$ALPIRAFEX_VERSION" > "$dist_dir/repository/README"
}

build_iso() {
	arch="$1"
	case "$arch" in
		x86_64|aarch64) ;;
		*) die "unsupported architecture: $arch" ;;
	esac

	install_build_dependencies
	prepare_aports
	prepare_builder_user
	prepare_keys
	configure_repositories

	[ -f "$repo_dir/packages/$arch/APKINDEX.tar.gz" ] || build_packages
	mkdir -p "$dist_dir/iso/$arch" "$work_dir/mkimage-$arch"
	chown -R "$builder":abuild "$dist_dir/iso/$arch" "$work_dir/mkimage-$arch"

	su -s /bin/sh "$builder" -c \
		"export ALPIRAFEX_REPO_BASE_URL='${ALPIRAFEX_REPO_BASE_URL:-}' ALPIRAFEX_PUBKEY_PATH='$ALPIRAFEX_PUBKEY_PATH' PACKAGER_PRIVKEY='$PACKAGER_PRIVKEY' PACKAGER_PUBKEY='$ALPIRAFEX_PUBKEY_PATH'; \
		cd '$aports_dir/scripts' && sh ./mkimage.sh \
		--tag "$ALPIRAFEX_VERSION" \
		--outdir "$dist_dir/iso/$arch" \
		--workdir "$work_dir/mkimage-$arch" \
		--arch "$arch" \
		--profile alpirafex \
		--repository "$repo_dir/packages" \
		--repository "https://dl-cdn.alpinelinux.org/alpine/$ALPINE_BRANCH/main" \
		--repository "https://dl-cdn.alpinelinux.org/alpine/$ALPINE_BRANCH/community" \
		--hostkeys \
		--checksum"
}

checksums() {
	sh "$repo_root/scripts/checksums.sh"
}

case "${1:-}" in
	bootstrap)
		install_build_dependencies
		prepare_aports
		prepare_builder_user
		prepare_keys
		;;
	build-packages)
		build_packages
		;;
	build-iso)
		[ $# -eq 2 ] || die "usage: build-iso x86_64|aarch64"
		build_iso "$2"
		;;
	checksums)
		checksums
		;;
	*)
		die "usage: bootstrap | build-packages | build-iso ARCH | checksums"
		;;
esac
