# foreman

[🇺🇸 English](README.md) | 🇧🇷 Português

Um plugin do Claude Code com skills orquestradoras que fazem o grilling de
features e bugs com você, executam planos, e lançam releases — delegando
cada linha de trabalho real pra sub-agentes dedicados. Nenhuma delas edita
código ou escreve um plano sozinha, assim como um foreman de verdade nunca
pega o martelo.

## Por quê

A maioria das configurações de "a IA programa por mim" junta planejamento,
construção, teste e lançamento numa única conversa, sem nenhuma separação de
responsabilidade — a mesma sessão que discutiu a feature com você é a mesma
que escreve o código, revisa o próprio trabalho, e decide sozinha que está
pronto. O foreman separa isso em papéis com fronteiras reais: um
orquestrador que só decide e delega, e sub-agentes que só constroem o que
foi pedido. Um hook reforça essa fronteira no nível da ferramenta, não só no
texto do prompt.

## A frota

```mermaid
flowchart TD
    U([Você]) <--> TL[["🧑‍💼 tech-lead\n(orquestrador)"]]

    TL -- "faz o grilling da ideia" --> GM["grill-me\n(opcional, mattpocock/skills)"]
    TL -- "código já existente?" --> AUDIT["improve-codebase-architecture\n+ writing-for-agents\n(opcional, só se precisar)"]

    TL -- "① plano" --> PL["planner"]
    PL -- "plano de volta p/ aprovação" --> TL

    TL -- "② construção" --> FE["frontend-dev"]
    TL -- "② construção" --> BE["backend-dev"]
    FE -. "auditoria impeccable" .-> FE

    TL -- "③ teste" --> QA["qa\n(testes reais de UI + API)"]
    QA -- "achou um bug" --> QB["qa-bugfix"]
    QB -- "corrigido" --> QA
    QA -- "tudo verde" --> TL

    TL -- "④ entrega" --> RM[["📦 release-manager\n(orquestrador)"]]
    RM --> SHIP(["commits limpos\n+ PR"])

    PR[["📋 plan-runner\n(orquestrador)"]] -- "aciona um delegado\npor passo do plano" --> PSB["plan-step-builder"]
    PSB -- "segue a própria skill\nbuild-plan do repositório" --> SHIP2(["passos mesclados\n+ verify-change"])
    U <--> PR

    style TL fill:#2d5aa0,color:#fff
    style RM fill:#2d5aa0,color:#fff
    style PR fill:#2d5aa0,color:#fff
```

Três skills orquestradoras, cada uma sua própria sessão, cada uma delegando
em vez de implementar:

| Skill | Papel | Nunca faz |
|---|---|---|
| `tech-lead` | Faz o grilling de uma feature/bug nova com você, reúne contexto, delega planejamento → construção → teste | Editar código, escrever o plano, decidir que terminou sem o `qa` confirmar |
| `plan-runner` | Executa um plano *já aprovado*, passo a passo, em repositórios que já têm suas próprias ferramentas de plano/build | Construir um passo sozinho, pular um passo marcado como "esperando você" |
| `release-manager` | Empacota as ondas terminadas em commits limpos e um PR | Implementar features, corrigir bugs |

## Um passo a passo

```mermaid
sequenceDiagram
    participant Você
    participant TL as tech-lead
    participant PL as planner
    participant FE as frontend-dev
    participant QA as qa
    participant RM as release-manager

    Você->>TL: "quero uma UI de calculadora"
    Note over TL: marca .orchestrator-active<br/>(hook passa a bloquear edições do próprio TL)
    TL->>Você: faz o grilling de escopo, biblioteca, padrão de UI
    Você->>TL: "Tailwind, sem dashboard, só a calculadora"
    TL->>PL: handoff-prompt.md (briefing grillado + decisões)
    PL->>TL: plano de implementação
    TL->>Você: "[PENDING] planner → plano pronto, aqui está"
    Você->>TL: aprova
    TL->>FE: handoff-prompt.md (plano + stack)
    FE->>FE: constrói, roda a auditoria impeccable
    FE->>TL: "[DONE] calculadora construída, estilizada"
    TL->>QA: roda testes reais antes do lançamento
    QA->>TL: "[DONE] só UI, sem backend, tudo verde"
    TL->>Você: release-handoff-prompt.md, pronto pro /release-manager
    Você->>RM: /release-manager (cola o handoff)
    RM->>RM: organiza commits, escreve a descrição do PR
    RM->>Você: "PR pronto pra revisão"
```

## Instalação

De onde você mantém suas fontes de plugin locais:

```bash
git clone https://github.com/MTBasso/foreman
claude plugin marketplace add ./foreman
claude plugin install foreman@foreman-marketplace
```

Depois abra uma sessão **nova** (as skills do plugin carregam no início da
sessão) e rode:

```
/tech-lead
```

## Uso

| Comando | O que faz |
|---|---|
| `/tech-lead [tópico]` | Transforma esta sessão no orquestrador tech-lead |
| `/tech-lead-status` | Mostra se o modo tech-lead está ativo e as decisões já registradas do projeto |
| `/plan-runner <plano>` | Executa um `docs/plans/<plano>.md` já aprovado, do início ao fim |
| `/release-manager` | Transforma esta sessão no release manager, pra empacotar o trabalho terminado |

O `tech-lead` também instala sozinho suas dependências opcionais na primeira
vez que roda (veja abaixo) — nada pra configurar à mão.

## O guardrail, não só um pedido no prompt

Enquanto qualquer skill orquestradora estiver ativa (o arquivo
`.orchestrator-active` existe na raiz do projeto), um hook `PreToolUse` nega
`Write`/`Edit`/`NotebookEdit` de cara — a única exceção é a própria
anotação de bookkeeping do `TECH_LEAD_MEMORY.md`. "O orquestrador nunca toca
em código" é reforçado no nível da ferramenta, não deixado só por conta do
modelo lembrar da regra.

Cada agente delegado (`frontend-dev`, `backend-dev`, `qa`, `qa-bugfix`,
`planner`, `plan-step-builder`) também carrega um bloco compartilhado de
disciplina de trabalho: preferir a ferramenta de edição em vez de recortar
linhas pelo Bash, se autoverificar com o lint/build do próprio projeto antes
de reportar concluído, nunca afirmar que algo funciona sem ter rodado de
verdade, parar depois de duas tentativas falhas da mesma correção em vez de
entrar em loop, não inventar uma API que nunca foi confirmada, e nunca
rodar um comando destrutivo sem autorização explícita.

## Conteúdo

**Skills**
- `skills/tech-lead` — o ponto de entrada principal (veja acima).
- `skills/plan-runner` — pra repositórios que já têm suas próprias
  ferramentas de plano/passo de build (ex: uma configuração de
  `build-plan`/`plan-status`/`verify-change`). Pula de propósito a
  revalidação do plano — isso já é feito pelo próprio grilling do tech-lead
  e pela sua aprovação.
- `skills/release-manager` — empacota ondas terminadas em commits + um PR.
- `skills/design-preview` — renderiza previews reais de HTML, com a
  biblioteca de verdade carregada, pra opções de UI serem escolhidas
  olhando, não lendo descrição.
- `skills/project-memory` — lê e escreve o `TECH_LEAD_MEMORY.md`, o
  registro por projeto de escolhas de stack, convenções e decisões,
  incluindo o raciocínio por trás de cada uma.

**Agentes** (acionados pelos orquestradores, nunca diretamente por você)
- `agents/planner.md` — transforma um briefing grillado num plano. Sem código.
- `agents/frontend-dev.md` / `agents/backend-dev.md` — constroem seguindo o
  plano e a stack já decididos no `TECH_LEAD_MEMORY.md`.
- `agents/qa.md` — roda testes reais de UI/API proativamente antes de
  qualquer entrega de release. Encontra problemas, nunca os corrige.
- `agents/qa-bugfix.md` — a contraparte reativa: corrige uma falha
  específica entregue por ele pelo `qa`, pela CI, ou por um comentário de
  revisão.
- `agents/plan-step-builder.md` — constrói e mescla um passo do
  `plan-runner`, seguindo a própria skill `build-plan` do repositório alvo.

**Comandos**: `/tech-lead`, `/tech-lead-status`, `/plan-runner`,
`/release-manager` — atalhos de entrada pras skills acima.

**Hooks**: `hooks/hooks.json` + `hooks/block-edit-during-orchestrator.sh` —
o guardrail descrito acima.

**Templates**
- `templates/handoff-prompt.md` — formato fixo de um prompt de delegação,
  pra contexto já decidido ser colado diretamente em vez de redescoberto
  pelo agente que recebe.
- `templates/handoff-summary.md` — o formato de linha de status
  `[PENDING]`/`[DONE]`/`[BLOCKED]` postado antes e depois de cada delegação.
- `templates/release-handoff-prompt.md` — o que o `tech-lead` entrega ao
  `release-manager` assim que as ondas de uma feature terminam.

**Evals**: `claude plugin eval .` roda verificações de regressão
formalizadas — um projeto vazio para e pergunta em vez de adivinhar, e o
guardrail de não-edição realmente bloqueia uma tentativa de edição em vez de
só pedir educadamente.

## Dependências opcionais

Quatro skills, de dois marketplaces diferentes, que o `tech-lead` usa quando
estão instaladas e cai no próprio julgamento quando não estão — nada quebra
de qualquer jeito, você só perde a abordagem específica daquela skill. O
`tech-lead` instala elas sozinho na primeira vez que roda, se estiverem
faltando:

```bash
claude plugin marketplace add mattpocock/skills
claude plugin install grill-me@mattpocock/skills
claude plugin install improve-codebase-architecture@mattpocock/skills
claude plugin install writing-for-agents@mattpocock/skills
claude plugin marketplace add pbakaus/impeccable
# confira o id exato do plugin com `claude plugin list`, depois algo como:
claude plugin install impeccable@impeccable
```

- `grill-me` — a entrevista de feature/bug.
- `improve-codebase-architecture` + `writing-for-agents` — rodam juntas, mas
  só numa base de código já existente que realmente parece precisar da
  auditoria — não de forma reflexiva em toda sessão.
- `impeccable` (de Paul Bakaus, não de Matt Pocock) — audita e corrige
  estilização genérica de "AI slop". O `frontend-dev` roda em tudo que
  constrói; o `qa` também roda em UI mais antiga, anterior a esse fluxo.

## Agradecimentos

Boa parte de como este plugin pensa fluxos de trabalho com agentes veio do
[Dictionary of AI
Coding](https://github.com/mattpocock/dictionary-of-ai-coding), conteúdo
gratuito de Matt Pocock — vale muito a leitura por conta própria. Esse
plugin também roda várias das skills dele diretamente (`grill-me`,
`improve-codebase-architecture`, `writing-for-agents`), creditadas em
Dependências opcionais acima.
