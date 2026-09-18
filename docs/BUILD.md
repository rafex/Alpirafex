# Alpirafex build

Alpirafex is built as a layer over Alpine Linux `v3.24`; Alpine's `aports`
tree is fetched at the revision recorded in `config/alpirafex.env` and under
`build/aports.ref`.

The host only needs Docker and Just. The actual package and ISO build runs in
an Alpine `3.24` container.

## First build

```sh
just bootstrap
just build-packages
just build-iso x86_64
just build-iso aarch64
just checksums
```

The first run generates a local signing key under `build/keys/` (ignored by
Git), so separate package and ISO commands reuse the same identity. For a real
release, provide a dedicated signing key outside Git and set `PACKAGER_PRIVKEY`
and `PACKAGER_PUBKEY` in the Alpine build environment.

## Public APK repository

Set `ALPIRAFEX_REPO_BASE_URL` to the base URL served by the Alpirafex domain,
for example:

```sh
export ALPIRAFEX_REPO_BASE_URL=https://packages.example.org/alpirafex/v3.24
just build-packages
```

Publish the contents of `dist/repository/` and the architecture-specific APK
indexes to the configured server. Never publish the private signing key.

## QEMU smoke tests

```sh
just test x86_64
just test aarch64
```

These are boot smoke tests. A release additionally requires a manual check of
`setup-alpine`, Xorg+i3, networking, OpenSSH, and package updates.
