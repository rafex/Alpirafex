#!/bin/sh

set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
arch="${1:-x86_64}"
iso="$(find "$repo_root/dist/iso/$arch" -maxdepth 1 -type f -name '*.iso' -print -quit 2>/dev/null || true)"

[ -n "$iso" ] || {
	echo "No ISO found for $arch. Run: just build-iso $arch" >&2
	exit 1
}

case "$arch" in
	x86_64) emulator="${QEMU_X86_64:-qemu-system-x86_64}" ;;
	aarch64) emulator="${QEMU_AARCH64:-qemu-system-aarch64}" ;;
	*) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

command -v "$emulator" >/dev/null 2>&1 || {
	echo "QEMU emulator not found: $emulator" >&2
	exit 1
}

echo "Boot smoke test for $iso"
case "$arch" in
	x86_64)
		exec timeout "${QEMU_TIMEOUT:-45}" "$emulator" \
			-cdrom "$iso" \
			-m 2048 \
			-boot d \
			-display none \
			-serial mon:stdio
		;;
	aarch64)
		exec timeout "${QEMU_TIMEOUT:-45}" "$emulator" \
			-machine virt \
			-cpu cortex-a72 \
			-cdrom "$iso" \
			-m 2048 \
			-nographic
		;;
esac
