#!/bin/sh

set -eu

host="$1"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p \
	"$tmp/etc/apk/keys" \
	"$tmp/etc/alpirafex" \
	"$tmp/etc/profile.d"

cat > "$tmp/etc/apk/world" <<-EOF
	alpirafex-base
	alpirafex-desktop
	alpirafex-suckless-tools
	alpirafex-branding
	alpirafex-openssh
	EOF

cat > "$tmp/etc/apk/repositories" <<-EOF
	https://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH:-v3.24}/main
	https://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH:-v3.24}/community
	EOF

if [ -n "${ALPIRAFEX_REPO_BASE_URL:-}" ]; then
	printf '%s\n' "${ALPIRAFEX_REPO_BASE_URL}/${ARCH}" >> "$tmp/etc/apk/repositories"
fi

if [ -n "${ALPIRAFEX_PUBKEY_PATH:-}" ] && [ -f "$ALPIRAFEX_PUBKEY_PATH" ]; then
	cp "$ALPIRAFEX_PUBKEY_PATH" "$tmp/etc/apk/keys/"
fi

cat > "$tmp/etc/alpirafex/release" <<-EOF
	NAME=Alpirafex
	VERSION=${ALPIRAFEX_VERSION:-0.1.0}
	BASE=Alpine
	ARCH=$ARCH
	HOSTNAME=$host
	EOF

cat > "$tmp/etc/profile.d/alpirafex.sh" <<-'EOF'
	export ALPIRAFEX_DISTRO=Alpirafex
	EOF

cat > "$tmp/etc/motd" <<-'EOF'

  Alpirafex — Xorg + i3 sobre Alpine Linux

  No es una distribución oficial de Alpine Linux.

EOF

tar -C "$tmp" -czf "$host.apkovl.tar.gz" .
