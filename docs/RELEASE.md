# Alpirafex release checklist

1. Confirm the Alpine branch, exact `aports` revision and package versions.
2. Build `x86_64` and `aarch64` packages in clean Alpine environments.
3. Sign the APK indexes with the offline Alpirafex release key.
4. Publish `dist/repository/` to the configured package server.
5. Build both ISO images with `ALPIRAFEX_REPO_BASE_URL` set to the public URL.
6. Run both QEMU boot smoke tests and complete the manual desktop/install test.
7. Generate SHA-256 files and verify them on a clean machine.
8. Publish the ISO files, `.sha256` checksums, `.asc` RSA signatures, public
   key and release manifest.

The private APK signing key must never be committed or uploaded with the
release artifacts. Rotate it only with a documented migration of the public
key in the ISO and package repository.

`just checksums` signs ISO images with the configured PEM RSA key using
OpenSSL. The `.asc` file is an Alpirafex ASCII-armored detached RSA signature;
verify it with the corresponding public key and `openssl dgst -sha256 -verify`.
