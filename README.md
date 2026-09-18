# Alpirafex

## Probar el piloto SpecNative

Este repositorio integra el adaptador versionado
[`agent_spec_native.just`](agent_spec_native.just). El piloto y el MCP se
mantienen en `Agent-SpecNative-Development`; no es necesario instalar el MCP
dentro de Alpirafex ni crear `.specnative/agent.toml`.

```bash
make install    # desde Agent-SpecNative-Development
export SPECNATIVE_AGENT_MODEL="nombre-del-modelo"
export OPENAI_API_KEY="tu-api-key"
just asn
```

`just asn` ejecuta primero el preflight. Si falta `AGENTS.md`, `spec-native/`
o algún documento requerido, termina sin iniciar el modelo ni modificar
archivos. Consulta [`docs/man_asn.md`](docs/man_asn.md) para la integración.

La interfaz independiente es `asn` (Agent Spec Native). Se instala una vez
desde el repositorio del agente con `make install` y puede ejecutarse desde
cualquier proyecto. `just asn` es sólo un alias conveniente. `asn-mcp --repo .`
expone el MCP para Codex, Claude u OpenCode; el agente busca primero un MCP
local en `.specnative/specnative_mcp.py` y después usa el MCP incluido.

## Construir Alpirafex

El proceso de construcción reproducible está documentado en
[`docs/BUILD.md`](docs/BUILD.md). Requiere Docker y Just en el host; los
paquetes APK y las ISO se construyen dentro de Alpine Linux.

```bash
just bootstrap
just build-packages
just build-iso x86_64
just build-iso aarch64
```

## Publicar el repositorio APK

El workflow `repository-image.yaml` construye una imagen nginx con
`dist/repository/` y la publica como
`ghcr.io/rafex/alpirafex-repository`. Requiere configurar en GitHub Actions
los Secrets `ALPIRAFEX_PACKAGER_PRIVKEY`, `ALPIRAFEX_PACKAGER_PUBKEY` y
`ALPIRAFEX_GITOPS_TOKEN`. El último debe poder abrir PRs en
`rafex/Alpirafex-gitops`.

El workflow nunca incluye la clave privada en la imagen; solo publica la clave
pública dentro de `dist/repository/keys/`.

El repositorio APK se sirve en
`https://alpirafex.rafex.io/alpirafex/v3.24/<arquitectura>/` mediante el
repositorio GitOps `rafex/Alpirafex-gitops`.

La primera edición usa Alpine `v3.24`, Xorg+i3 y no incluye una sesión
Wayland. Consulta [`docs/RELEASE.md`](docs/RELEASE.md) antes de publicar una
release.

## Licencia

La licencia MIT de este repositorio se aplica a los scripts de
personalización, configuraciones, metapaquetes y elementos de branding de
Alpirafex creados y distribuidos en este proyecto. Consulta el archivo
[`LICENSE`](LICENSE) para ver el texto completo.

Los paquetes de software individuales que puedan distribuirse junto con
Alpirafex —por ejemplo, el kernel, BusyBox y otras dependencias— conservan
sus propias licencias originales (GPL, MIT, BSD u otras). La licencia MIT de
este repositorio no sustituye ni amplía esas licencias.

Cuando se incluya código o contenido de terceros, deben conservarse sus
avisos de copyright y las condiciones de sus licencias correspondientes.
