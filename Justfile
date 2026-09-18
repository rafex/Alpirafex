set dotenv-load

# Adaptador local del piloto. Sobrescribe SPECNATIVE_PILOT_ROOT si el agente
# vive en otra ruta; el MCP seguirá escribiendo en este repositorio.
pilot_root := env_var_or_default("SPECNATIVE_PILOT_ROOT", "/Users/rafex/repository/github/rafex/Agent-SpecNative-Development")
pilot_python := pilot_root + "/.specnative/.venv/bin/python"
pilot_source := pilot_root + "/pilot/src"

@default:
    just --list

run:
    PYTHONPATH="{{ pilot_source }}" "{{ pilot_python }}" -m specnative_pilot.cli --repo . --config .specnative/agent.toml

batch:
    PYTHONPATH="{{ pilot_source }}" "{{ pilot_python }}" -m specnative_pilot.cli --repo . --config .specnative/agent.toml --question-mode batch
