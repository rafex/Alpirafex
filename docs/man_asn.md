# `just asn`

## Propósito

Inicia el piloto interactivo de SpecNative usando Alpirafex como repositorio
destino. El agente y el MCP se mantienen en el repositorio externo del agente.

## Configuración

```bash
export SPECNATIVE_AGENT_ROOT=/Users/rafex/repository/github/rafex/Agent-SpecNative-Development
export SPECNATIVE_AGENT_MODEL="nombre-del-modelo"
export OPENAI_API_KEY="..."
```

Alpirafex debe tener contexto SpecNative válido. `just asn` ejecuta el
preflight antes de iniciar el modelo y termina sin escribir si falla.

## Uso

```bash
just asn
```

El comando canónico no depende de Just:

```bash
uv tool install --editable /Users/rafex/repository/github/rafex/Agent-SpecNative-Development/pilot
export SPECNATIVE_AGENT_ROOT=/Users/rafex/repository/github/rafex/Agent-SpecNative-Development
asn --repo /ruta/al/proyecto
```

`just asn` sólo delega en el ejecutable instalado dentro de
`SPECNATIVE_AGENT_ROOT`.

Dentro de la sesión, `/template nombre` es la única forma de solicitar una
plantilla y siempre requiere confirmación explícita.
