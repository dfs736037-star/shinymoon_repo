# Ollama — integração local (zero tokens Cursor)

Economiza tokens do Cursor delegando tarefas repetitivas a modelos locais via MCP `ollama-mcp`.

## Instalação rápida

```powershell
cd "d:\SteamLibrary\steamapps\common\csgo legacy\nl\scripts\shinymoon_1"
.\.cursor\setup\install-ollama.ps1
```

Opções:

| Flag | Efeito |
|------|--------|
| `-ModelSize 3b` | Modelo menor (~2 GB VRAM) |
| `-ModelSize 7b` | **Padrão** — bom equilíbrio (~5 GB) |
| `-ModelSize 14b` | Melhor qualidade (~10 GB) |
| `-SkipModelPull` | Só configura MCP, não baixa modelo |
| `-SkipMcpMerge` | Só Ollama/modelo, não altera `mcp.json` |

Depois: **reinicie o Cursor** ou recarregue MCP em Settings → MCP.

---

## O que foi configurado

| Peça | Função |
|------|--------|
| **Ollama** (`localhost:11434`) | Runtime local de LLM |
| **MCP `ollama`** (`ollama-mcp`) | Tools: chat, generate, list, pull, embed… |
| **`OLLAMA_ORIGINS=*`** | Necessário para Chat override no Cursor |
| **Modelo padrão** | `qwen2.5-coder:7b` — foco em código |

Ferramentas locais **sem LLM** (sempre ligadas, grátis):

- `shinymoon-alpha-tools` — docs Neverlose, busca Lua, memória, test logs
- `graphify` — grafo do código
- `sequential-thinking` — decomposição de planos

---

## Mini guia: local vs cloud

### Use **Ollama MCP** (grátis, local)

Peça explicitamente no chat do Agent:

| Tarefa | Tool / prompt |
|--------|----------------|
| Resumir diff ou log longo | `ollama_generate` / `ollama_chat` — "Resuma este diff em 5 bullets" |
| Mensagem de commit | "Use ollama para gerar conventional commit deste diff" |
| Rascunho de label/descrição UI | "ollama: 3 opções de label para slider de opacity" |
| Comparar strings de modo AA | "ollama: liste diferenças entre estes dois trechos Lua" |
| Embeddings / busca semântica local | `ollama_embed` |
| Ver modelos disponíveis | `ollama_list` |

**Não precisa** de raciocínio profundo — só texto mecânico ou brainstorming barato.

### Use **Cursor cloud** (`/code`, Agent, subagentes)

| Tarefa | Por quê |
|--------|---------|
| Editar `shinymoon_alpha.lua` | Contexto grande + API Neverlose |
| Anti-aim / defensive / arquitetura | Lógica cruzada, regressões caras |
| `/opsx-propose`, `/opsx-apply` | Specs + multi-seção |
| Review final (`shinymoon-review`) | Qualidade e regressão |
| Debug de callback Neverlose | Precisa graphify + docs + raciocínio |

### Use **ferramentas MCP determinísticas** (sempre, antes de LLM)

| Tarefa | Tool |
|--------|------|
| Onde está X no código? | `graphify query` |
| Doc de API Neverlose | `fetch_neverlose_doc` (shinymoon-alpha-tools) |
| Buscar símbolo Lua | `search_project` |
| Guardar nota de sessão | `memory_add` |

Ordem ideal: **graphify/MCP docs → Ollama para rascunho → Cursor cloud para implementar**.

---

## Chat local no Cursor (opcional)

Para **Chat / Cmd+K** sem gastar quota:

1. Cursor → **Settings → Models**
2. **OpenAI API Key**: `ollama` (qualquer placeholder)
3. **Override OpenAI Base URL**: `http://127.0.0.1:11434/v1`
4. Adicionar modelo: `qwen2.5-coder:7b`
5. Desmarcar modelos cloud nessa sessão se quiser 100% local

Limitações conhecidas:

- **Tab autocomplete** continua cloud na maioria dos planos
- **Agent mode** com modelo local é mais fraco em arquivos grandes
- Prefira Agent cloud + MCP Ollama para offload

---

## Prompts prontos (copiar no Agent)

```
Resuma o git diff atual usando ollama_chat (qwen2.5-coder:7b). Não edite arquivos.
```

```
Use ollama_generate para 5 mensagens de commit conventional em português do diff staged.
```

```
Antes de /code: use graphify query "defensive flicker" e ollama_chat para listar hipóteses. Depois pare — não implemente.
```

```
Brainstorm de labels Apple-style para watermark opacity — só ollama, 3 opções curtas.
```

---

## Verificação

```powershell
# Ollama respondendo
curl http://127.0.0.1:11434/api/tags

# Modelo instalado
ollama list

# Teste rápido
ollama run qwen2.5-coder:7b "Say OK in one word"
```

No Cursor: Settings → MCP → `ollama` deve estar **verde**. Teste no chat:

> Use ollama_list e diga quantos modelos locais existem.

---

## Troubleshooting (Windows)

| Problema | Solução |
|----------|---------|
| MCP `ollama` vermelho | Reinicie Cursor; confirme Node em `C:\Program Files\nodejs\` |
| `spawn npx ENOENT` | `mcp.json` já usa `cmd.exe` + caminho absoluto do `npx.cmd` |
| Ollama não conecta | Abra o app Ollama ou `ollama serve` |
| Chat override CORS | `OLLAMA_ORIGINS=*` (User env) — reabra terminal/Cursor |
| Modelo lento | Use `3b` ou feche outros apps na GPU |
| VRAM insuficiente | `install-ollama.ps1 -ModelSize 3b` |

---

## Matriz resumida

```
Explorar código     → graphify (grátis)
Docs Neverlose      → shinymoon-alpha-tools (grátis)
Resumo / commit     → ollama MCP (grátis)
Implementar Lua     → /code + Cursor cloud
Feature grande      → /opsx-propose → /opsx-apply
UI mockup           → open-design MCP
```
