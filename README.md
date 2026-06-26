# Shinymoon

Neverlose CS:GO HVH ambient script + cloud config API + AI tooling.

| Peça | Caminho | Repo remoto |
|------|---------|-------------|
| **Script principal** | `shinymoon_alpha.lua` | [shinymoon_repo](https://github.com/dfs736037-star/shinymoon_repo) |
| **Módulo NL** | `def_voice_decoders.lua` | (mesmo repo, mesma pasta — `require` do Neverlose) |
| **Cloud API** | `shinymoon-cloud/` | [shinymoon-cloud1](https://github.com/dfs736037-star/shinymoon-cloud1) |
| **Specs / planos** | `openspec/` | shinymoon_repo |
| **Grafo de código** | `graphify-out/` | gerado localmente |
| **Referências HVH** | `reference/legacy/` | só leitura para IA |

## Carregar no Neverlose

A pasta `shinymoon_1` fica em `nl/scripts/`. Carregue **`shinymoon_alpha.lua`** — não mova para subpasta.

## Estrutura rápida

```
shinymoon_1/
├── shinymoon_alpha.lua      # script (editar aqui)
├── def_voice_decoders.lua   # dependência runtime
├── shinymoon_icon.png
├── reference/
│   ├── legacy/              # scripts HVH de referência (não editar)
│   └── iapeek_base          # snippet ia-peek
├── docs/                    # notas, telemetria, netvars
├── openspec/                # specs + changes ativos
├── graphify-out/            # knowledge graph (graph.html)
├── shinymoon-cloud/         # submodule — API Railway
├── .cursor/                 # rules, skills, MCP, commands
└── AGENTS.md                # instruções para agentes IA
```

Detalhes: [`docs/REPO_MAP.md`](docs/REPO_MAP.md).

## Git — dois repos

1. **Raiz** (`shinymoon_repo`) — script, openspec, tooling.
2. **`shinymoon-cloud/`** — submodule Python/FastAPI; deploy Railway separado.

```powershell
# Clonar tudo
git clone https://github.com/dfs736037-star/shinymoon_repo.git shinymoon_1
cd shinymoon_1
git submodule update --init --recursive
```

## Branches

| Branch | Uso |
|--------|-----|
| `cursor/plan-first-openspec-setup` | default remoto — setup OpenSpec + tooling |
| `master` | branch local inicial |

## OpenSpec (changes ativos)

| Change | Estado |
|--------|--------|
| `dtc-reliability` | proposta — overhaul DTC send-tick |
| `dtc-hidden-aa` | **REVERTED** — manter só registro |

Workflow: `/opsx-explore` → `/opsx-propose` → aprovar → `/opsx-apply` → `/opsx-archive`.

## Comandos úteis

```powershell
# Atualizar grafo após editar Lua
graphify update .

# Cloud API local (tunnel obrigatório para testar no NL)
cd shinymoon-cloud
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```
