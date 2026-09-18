profile_alpirafex() {
	profile_base
	profile_abbrev="alp"
	title="Alpirafex"
	desc="Alpirafex: a minimal Xorg and i3 desktop built on Alpine Linux."
	image_name="alpirafex"
	image_ext="iso"
	output_format="iso"
	arch="aarch64 x86_64"
	apks="$apks
		alpirafex-base
		alpirafex-desktop
		alpirafex-suckless-tools
		alpirafex-branding
		alpirafex-openssh
	"
	apkovl="genapkovl-alpirafex.sh"
	hostname="alpirafex"
}
