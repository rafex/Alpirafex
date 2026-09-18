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
