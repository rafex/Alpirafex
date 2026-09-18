set dotenv-load

repo_root := justfile_directory()
alpine_image := env_var_or_default("ALPIRAFEX_ALPINE_IMAGE", "alpine:3.24")
repo_url := env_var_or_default("ALPIRAFEX_REPO_BASE_URL", "")
packager_privkey := env_var_or_default("PACKAGER_PRIVKEY", "")
packager_pubkey := env_var_or_default("PACKAGER_PUBKEY", "")

import 'agent_spec_native.just'

@default:
    just --list

bootstrap:
    docker run --rm --privileged -v "{{ repo_root }}:/src" -w /src "{{ alpine_image }}" sh /src/scripts/alpine-build.sh bootstrap

build-packages:
    docker run --rm --privileged -v "{{ repo_root }}:/src" -w /src -e ALPIRAFEX_REPO_BASE_URL="{{ repo_url }}" -e PACKAGER_PRIVKEY="{{ packager_privkey }}" -e PACKAGER_PUBKEY="{{ packager_pubkey }}" "{{ alpine_image }}" sh /src/scripts/alpine-build.sh build-packages

build-iso arch:
    docker run --rm --privileged -v "{{ repo_root }}:/src" -w /src -e ALPIRAFEX_REPO_BASE_URL="{{ repo_url }}" -e PACKAGER_PRIVKEY="{{ packager_privkey }}" -e PACKAGER_PUBKEY="{{ packager_pubkey }}" "{{ alpine_image }}" sh /src/scripts/alpine-build.sh build-iso "{{ arch }}"

checksums:
    sh scripts/checksums.sh

test arch="x86_64":
    sh scripts/test-iso.sh "{{ arch }}"
