# `just asn`

## Propósito

Inicia el piloto interactivo de SpecNative usando Alpirafex como repositorio
destino. El agente y el MCP se mantienen en el repositorio externo del agente.

## Configuración

```bash
export SPECNATIVE_AGENT_MODEL="nombre-del-modelo"
export OPENAI_API_KEY="..."
```

Alpirafex debe tener contexto SpecNative válido. `just asn` ejecuta el
preflight antes de iniciar el modelo y termina sin escribir si falla.

## Uso

```bash
just asn
asn --repo .
asn-mcp --repo .         # MCP para Codex, Claude u OpenCode
```

El comando canónico no depende de Just:

```bash
make install
```

`asn` busca el MCP local más cercano en `.specnative/specnative_mcp.py`,
subiendo por los directorios padre. Si no lo encuentra, usa el MCP incluido
en el paquete global. Un MCP local encontrado que falle no activa fallback.
`just asn` sólo delega en el ejecutable instalado.

Dentro de la sesión, `/template nombre` es la única forma de solicitar una
plantilla y siempre requiere confirmación explícita.
