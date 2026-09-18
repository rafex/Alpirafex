# Alpirafex

## Probar el piloto SpecNative

Este repositorio usa temporalmente el piloto ubicado en
`Agent-SpecNative-Development`. La configuración local del MCP está en
`.specnative/agent.toml` y no se versiona.

```bash
export SPECNATIVE_AGENT_MODEL="nombre-del-modelo"
export OPENAI_API_KEY="tu-api-key"
just run
```

Para preguntas por bloques:

```bash
just batch
```

Puedes cambiar la ubicación del piloto con `SPECNATIVE_PILOT_ROOT`.

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
