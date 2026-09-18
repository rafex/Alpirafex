# Alpirafex

## Probar el piloto SpecNative

Este repositorio integra el adaptador versionado
[`agent_spec_native.just`](agent_spec_native.just). El piloto y el MCP se
mantienen en `Agent-SpecNative-Development`; no es necesario instalar el MCP
dentro de Alpirafex ni crear `.specnative/agent.toml`.

```bash
export SPECNATIVE_AGENT_ROOT=/Users/rafex/repository/github/rafex/Agent-SpecNative-Development
export SPECNATIVE_AGENT_MODEL="nombre-del-modelo"
export OPENAI_API_KEY="tu-api-key"
just asn
```

`just asn` ejecuta primero el preflight. Si falta `AGENTS.md`, `spec-native/`
o algún documento requerido, termina sin iniciar el modelo ni modificar
archivos. Consulta [`docs/man_asn.md`](docs/man_asn.md) para la integración.

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
