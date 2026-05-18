# Análise de Cobertura de Código — UVM Testbench para ALU de 8 bits

**Disciplina:** MIC61 — Metodologias de Verificação Integrada  
**Simulador:** Cadence Xcelium 23.09-s013 com IMC (Cadence Verisium Manager 23.09)  
**Seed:** 10 | **Data:** 18/05/2026

---

## Questão 3 — Análise de Cobertura com IMC

### 3.1 Cobertura de FSM em `alu_core`

**Não é possível realizar análise de cobertura de FSM para o bloco `alu_core`.**

A justificativa é extraída diretamente do log de elaboração do Xcelium:

```
Extracting FSMs for coverage:
    worklib.alu_core
    worklib.alu_top
    worklib.top_tb
Total FSMs extracted = 0
```

O elaborador inspecionou os três módulos e não encontrou nenhuma FSM. Isso ocorre porque o `alu_core` é inteiramente **combinacional** — sua única lógica é uma cadeia de operadores ternários (`?:`) que mapeia o valor de `sel_ip` diretamente para `data_op` sem qualquer estado sequencial:

```systemverilog
assign data_op = (sel_ip == 3'b000) ? data_ip_1 + data_ip_2 :   // ADD
                 (sel_ip == 3'b001) ? data_ip_1 - data_ip_2 :   // SUB
                 ...
                 'd0;
```

Sem registros de estado (`always @(posedge clk)`) e sem laços de realimentação, não há grafo de estados a extrair. O módulo `alu_top` (wrapper registrado) também não implementa uma FSM explícita — seus `always` blocos controlam sinais de handshake (`available_r`, `valid_op`, `ready_op`) de forma direta, não codificando estados em variáveis enumeradas. Por essas razões, o IMC reporta `FSMs extracted = 0` e a aba de cobertura FSM permanece vazia.

---

### 3.2 Resultado Geral de Cobertura

A tabela abaixo consolida os resultados obtidos no IMC **após a aplicação das exclusões** definidas no arquivo `run_xcelium/refine.vRefine`. Sem as exclusões o resultado bruto de block coverage era de 91,3% e o de expression era 83,3%.

| Tipo de Cobertura | Instância / Sinal | Resultado (após exclusões) | Prioritário para melhoria? |
|---|---|---|---|
| **Block** | `top_tb/dut` — total | **100%** | — |
| Block | Block 7 (`design.sv:51`) — implicit else de `else if(~valid_ip \|\| valid_int_ip_r)` | Excluído (estruturalmente inalcançável) | Não — ver §3.3 |
| Block | Block 23 (`design.sv:80`) — implicit else de `else if(available_r)` | Excluído (estruturalmente inalcançável) | Não — ver §3.3 |
| **Expression** | `top_tb/dut` — total | **100%** | — |
| Expression | Linha 51: `(~valid_ip) \|\| valid_int_ip_r`, caso T1=1/T2=0 | Excluído (estruturalmente inalcançável) | Não — ver §3.3 |
| **Toggle** | `top_tb/dut` — total | **100%** | — |
| Toggle | `rst` (0→1 e 1→0) | **100%** (corrigido no TB) | — |
| Toggle | `data_ip_1_w` — 8 bits | Excluído (wire morto, nunca conectado) | Não — ver §3.3 |
| Toggle | `data_ip_2_w` — 8 bits | Excluído (wire morto, nunca conectado) | Não — ver §3.3 |
| **Functional** (`cg_sel`) | `cp_sel_ip` — ADD (3'b000) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — SUB (3'b001) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — MULT (3'b010) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — LSH (3'b011) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — RSH (3'b100) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — INCR (3'b101) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — DECR (3'b110) | **100%** (bin coberto) | — |
| Functional | `cp_sel_ip` — invalid (3'b111) | `ignore_bins` (correto por spec) | — |
| **FSM** | `alu_core`, `alu_top` | Não extraída (0 FSMs) | Não aplicável — ver §3.1 |

**Resultado geral: 100% em todas as métricas aplicáveis após exclusões justificadas.**

---

### 3.3 Classificação dos Itens Excluídos

Nenhum dos itens excluídos é **prioritário para melhoria do testbench**, pois todos são **defeitos estruturais do RTL**, não lacunas de estímulo. A tabela a seguir detalha cada caso:

| Item | Causa raiz | É prioritário melhorar? | Justificativa |
|---|---|---|---|
| Block 7 — implicit else (`design.sv:51`) | `else if(~valid_ip \|\| valid_int_ip_r)` é avaliado apenas quando `valid_ip = 0` (já no `else` do `if(valid_ip)`), tornando `~valid_ip = 1` sempre verdadeiro. O implicit else exigiria que a expressão fosse falsa, o que é uma contradição lógica impossível em simulação 2-state. | **Não** | Nenhum estímulo pode atingir este bloco. A solução correta é refatorar o RTL substituindo `else if(~valid_ip \|\| valid_int_ip_r)` por simplesmente `else`. |
| Block 23 — implicit else (`design.sv:80`) | `else if(available_r)` é redundante: para alcançar este branch, o `if(~available_r)` acima já foi falso, garantindo `available_r = 1`. O implicit else exigiria `available_r = 0` — contradição impossível. | **Não** | Mesma origem: bug de RTL. Substituir por `else` elimina o problema. |
| Expression T1=1/T2=0 (`design.sv:51`) | A expressão `(~valid_ip) \|\| valid_int_ip_r` é avaliada somente no branch `else` de `if(valid_ip)`, onde `valid_ip = 0` é garantido. Assim `~valid_ip = 1` sempre, e a combinação T1=1/T2=0 (que tornaria a expressão falsa) é impossível. | **Não** | Consequência direta do mesmo problema do Block 7. |
| Toggle `data_ip_1_w` / `data_ip_2_w` | Os wires são declarados em `design.sv` (linhas 27–28) mas **nenhuma atribuição** (`assign`) os dirige e **nenhuma porta** do `alu_core` está conectada a eles. Ficam em X durante toda a simulação. | **Não** | Código morto no RTL. A solução é remover as declarações desnecessárias de `design.sv`. |

---

## Questão 4 — Melhorias no Testbench para Aumentar a Cobertura

### 4.1 Estratégia Adotada

A análise inicial dos resultados brutos do IMC revelou três categorias de itens não cobertos:

1. **Toggle do sinal `rst`** — apenas a transição 1→0 era capturada.
2. **Itens estruturalmente inalcançáveis** — Blocks 7 e 23, expressão na linha 51, e os wires `data_ip_1_w`/`data_ip_2_w`.
3. **Cobertura funcional de `sel_ip`** — todos os 7 valores válidos precisavam ser exercitados.

Para cada categoria foi adotada uma estratégia diferente:

#### Categoria 1 — Toggle de `rst`: correção no driver

**Problema identificado:** O `alu_driver.sv` iniciava o reset com `vif.rst <= 1'b1` partindo do estado indefinido X. O IMC só registra transições 0→1 e 1→0; a transição X→1 não conta. Portanto apenas o deassert (1→0) era capturado.

**Solução implementada:** Após o pulso de reset inicial (rst alto por 5 ciclos), foi adicionado um pulso extra de curta duração que força as transições 0→1→0 de forma explícita:

```systemverilog
// reset inicial: rst=1 por 5 ciclos, depois rst=0
// pulso extra para garantir ambas as transições no IMC:
vif.rst <= 1'b0;         // assegura nível 0 conhecido
@(posedge vif.clk);
vif.rst <= 1'b1;         // transição 0→1 capturada pelo IMC
@(posedge vif.clk);
vif.rst <= 1'b0;         // transição 1→0 capturada pelo IMC
```

Resultado: toggle de `rst` passou a 100% sem necessidade de exclusão.

#### Categoria 2 — Itens inalcançáveis: exclusão via `refine.vRefine`

Como os itens são artefatos de código RTL redundante ou morto — e não lacunas de verificação —, a abordagem correta é **excluí-los com justificativa documentada**, e não tentar cobri-los via estímulo (o que é impossível por construção). O arquivo `run_xcelium/refine.vRefine` foi gerado pela GUI do IMC com comentários explicativos para cada exclusão.

#### Categoria 3 — Cobertura funcional de `sel_ip`: covergroup + sequência direcionada

Foi implementado o `alu_cov_agent.sv` com o covergroup `cg_sel`:

```systemverilog
covergroup cg_sel with function sample(alu_tx item);
  option.goal = 100;
  cp_sel_ip: coverpoint item.sel_ip {
    bins add  = {ALU_ADD };
    bins sub  = {ALU_SUB };
    bins mult = {ALU_MULT};
    bins lsh  = {ALU_LSH };
    bins rsh  = {ALU_RSH };
    bins incr = {ALU_INCR};
    bins decr = {ALU_DECR};
    ignore_bins invalid = {3'b111};
  }
endgroup
```

O `alu_cov_agent` recebe transações de dois `uvm_analysis_imp` distintos:
- `imp_active` — conectado ao monitor do agente ativo (captura entradas); é aqui que `cg_sel.sample()` é chamado.
- `imp_passive` — conectado ao monitor do agente passivo (captura saídas); usado para extensibilidade futura.

A amostragem é feita no `write_active()` pois o `sel_ip` é um campo de entrada, capturado pelo monitor ativo no momento em que a transação é enviada ao DUT.

Para garantir que todos os 7 valores de `sel_ip` fossem exercitados, as constraints do `alu_tx` foram revisadas para **não excluir** nenhum valor válido (3'b000 a 3'b110), e a sequência `alu_seq` foi configurada com iterações suficientes para cobrir todos os bins por randomização.

### 4.2 Resultados Alcançados

| Métrica | Antes das melhorias | Após as melhorias |
|---|---|---|
| Block coverage | 91,3% | **100%** (com exclusões justificadas) |
| Expression coverage | 83,3% | **100%** (com exclusões justificadas) |
| Toggle coverage | < 100% (`rst`, `data_ip_1_w`, `data_ip_2_w`) | **100%** (rst corrigido; wires mortos excluídos) |
| Functional coverage (`cg_sel`) | Não implementado | **100%** (todos os 7 bins cobertos) |
| FSM coverage | Não aplicável | Não aplicável (0 FSMs extraídas) |

### 4.3 Limitações e Observações

- Os itens excluídos via `refine.vRefine` **não representam lacunas de verificação funcional**: toda a lógica alcançável do design é coberta. As exclusões são rastreáveis e documentadas com justificativa técnica dentro do próprio arquivo XML de refinamento.
- A solução definitiva para os Blocks 7 e 23 e para os wires mortos é **refatorar o RTL** (`design.sv`), substituindo as condições redundantes por `else` simples e removendo as declarações mortas. Isso eliminaria a necessidade das exclusões e tornaria o código mais legível.
- A cobertura de FSM permanece inaplicável a este design por sua natureza combinacional, conforme confirmado pelo elaborador do Xcelium (`Total FSMs extracted = 0`).
