#!/bin/sh

set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
dist_dir="${ALPIRAFEX_DIST_DIR:-$repo_root/dist}"

command -v sha256sum >/dev/null 2>&1 && checksum_cmd="sha256sum" || checksum_cmd="shasum -a 256"
privkey="${PACKAGER_PRIVKEY:-$repo_root/build/keys/alpirafex.rsa}"

sign_iso() {
	artifact="$1"
	signature="${artifact%.iso}.asc"
	[ -f "$privkey" ] || return 0
	command -v openssl >/dev/null 2>&1 || return 0

	{
		echo '-----BEGIN ALPIRAFEX SHA256 SIGNATURE-----'
		openssl dgst -sha256 -sign "$privkey" "$artifact" | openssl base64 -A
		echo
		echo '-----END ALPIRAFEX SHA256 SIGNATURE-----'
	} > "$signature"
}

find "$dist_dir" -type f \( -name '*.iso' -o -name '*.apk' \) -print 2>/dev/null |
while IFS= read -r artifact; do
	case "$artifact" in
		*.iso) checksum_file="${artifact%.iso}.sha256" ;;
		*) checksum_file="$artifact.sha256" ;;
	esac
	(
		cd "$(dirname "$artifact")"
		$checksum_cmd "$(basename "$artifact")" > "$(basename "$checksum_file")"
	)

	case "$artifact" in
		*.iso) sign_iso "$artifact" ;;
	esac
printf '%s\n' "$artifact"
done

if ! find "$dist_dir" -type f \( -name '*.iso' -o -name '*.apk' \) -print -quit 2>/dev/null | grep -q .; then
	echo "No ISO or APK artifacts found under $dist_dir" >&2
	exit 1
fi
