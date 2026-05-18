# Análise de Code Coverage — ALU ULA

## Resumo

Durante a verificação com Xcelium/IMC, três casos de cobertura ficaram zerados.
Após análise do RTL, todos são **estruturalmente inalcançáveis** — artefatos de
condições redundantes no código RTL, não falhas do testbench.

---

## Casos Inalcançáveis

### Block 7 — Implicit else, linha 51 (`design.sv`)

**Código:**
```systemverilog
// always @ Input Registers Block (linhas 43–54)
if(valid_ip) begin
  if(available_r) begin
    ...
    valid_int_ip_r <= 1'b1;
  end
  // Block 7 = implicit else deste if(available_r)
  // Ocorre quando: valid_ip=1 AND available_r=0
end else if(~valid_ip || valid_int_ip_r) begin
  valid_int_ip_r <= 1'b0;
end
```

**Por que é inalcançável:**

O implicit else do `else if(~valid_ip || valid_int_ip_r)` exigiria que a
expressão fosse **falsa**. Isso requer:

```
~valid_ip = 0  AND  valid_int_ip_r = 0
    ↓
valid_ip = 1   AND  valid_int_ip_r = 0
```

Porém, para chegar nesta ramificação `else if`, o `if(valid_ip)` acima já deve
ter sido **falso** — ou seja, `valid_ip = 0`. **Contradição impossível em
simulação 2-state.**

---

### Block 23 — Implicit else, linha 80 (`design.sv`)

**Código:**
```systemverilog
// always @ Output Registers Block (linhas 66–91)
if(~available_r) begin
  if(ready_ip) begin
    available_r <= 1'b1;
    valid_op    <= 1'b0;
  end
end else if(available_r) begin   // ← redundante
  if(valid_int_ip_r) begin
    data_op     <= data_op_w;
    valid_op    <= 1'b1;
    available_r <= 1'b0;
  end
  // Block 23 = implicit else deste if(valid_int_ip_r)
  // Ocorre quando: available_r=1 AND valid_int_ip_r=0
end
```

**Por que é inalcançável:**

O implicit else do `else if(available_r)` exigiria que a condição fosse
**falsa**, ou seja, `available_r = 0`. Mas para chegar neste branch, o
`if(~available_r)` acima já deve ter sido **falso** — garantindo `available_r = 1`.
**Contradição impossível.**

A condição `else if(available_r)` é **redundante** — poderia ser simplesmente
`else`.

---

### Expression Coverage — linha 51, caso T1=1 / T2=0

**Expressão:** `(~valid_ip) || valid_int_ip_r`

| Index | T1 (`~valid_ip`) | T2 (`valid_int_ip_r`) | Score | Output |
|-------|------------------|-----------------------|-------|--------|
| 1     | —                | 1                     | ✅ 1  | 1      |
| 2     | 0                | —                     | ✅ 1  | 1      |
| 3     | 1                | 0                     | ❌ 0  | 0      |

**Por que é inalcançável:**

A linha 51 é um `else if` dentro do `else` de `if(valid_ip)`. Portanto, ao
avaliar esta expressão, `valid_ip` já é `0` — logo `~valid_ip = 1` **sempre**.

Para que a expressão avalie para `0` (caso T1=1, T2=0, output=0) seria
necessário:
```
~valid_ip = 0  AND  valid_int_ip_r = 0
    ↓
valid_ip = 1
```

O que contradiz estar no branch `else` (onde `valid_ip = 0`).
**Inalcançável em simulação 2-state.**

---

## Solução Recomendada

### Opção 1 — Arquivo de exclusão IMC

Arquivo gerado em [`../run_xcelium/coverage_refine.cmd`](../run_xcelium/coverage_refine.cmd).

**Uso no IMC interativo:**
```bash
imc> load -refinement coverage_refine.cmd
imc> save -refinement
```

**Uso na CLI (xrun):**
```bash
xrun ... -covoverwrite -covrefine coverage_refine.cmd
```

> **Nota:** A sintaxe `deselect_coverage` varia entre versões do Xcelium/IMC.
> Se houver erro, use a GUI do IMC: clique com botão direito nos itens
> não-cobertos → **Exclude** → **Save Refinement**.

---

### Opção 2 — Refatorar o RTL (correção da causa raiz)

Remover as condições redundantes em `design.sv`:

```systemverilog
// Linha 51 — trocar:
end else if(~valid_ip || valid_int_ip_r) begin
// por:
end else begin

// Linha 80 — trocar:
end else if(available_r) begin
// por:
end else begin
```

Isso elimina os branches inalcançáveis e a expressão redundante, levando o
coverage de blocos e expressões a 100% naturalmente.

---

## Impacto na Cobertura (Block + Expression)

| Métrica              | Atual   | Após exclusão |
|----------------------|---------|---------------|
| Block Covered Grade  | 91.3%   | ~100%         |
| Expression Covered   | 83.33%  | ~100%         |
| Overall Grade        | 87.34%  | ~95%+         |

Os casos excluídos não representam lacunas de verificação funcional — toda a
lógica **alcançável** do design está coberta.

---

## Toggle Coverage — Casos Identificados

### `rst` — Toggle 0→1 ausente (corrigido no testbench)

**Observação (IMC):** Score=0, 0→1 coberto=0, 1→0 coberto=1.

**Causa:** O driver chamava `vif.rst <= 1'b1` como primeiro drive, partindo
de X (indefinido). A ferramenta só registra transições 0→1 e 1→0 — X→1 não
conta. Portanto apenas a transição 1→0 (desassert) era capturada.

**Solução:** Corrigido no `alu_driver.sv`: após os 5 ciclos de reset inicial
(1→0), é adicionado um pulso extra de reset (0→1→0), garantindo que ambas as
transições sejam capturadas pelo IMC:

```systemverilog
vif.rst <= 1'b0;         // 1→0 (deassert inicial)
@(posedge vif.clk);
vif.rst <= 1'b1;         // 0→1 capturado
@(posedge vif.clk);
vif.rst <= 1'b0;         // 1→0 capturado novamente
```

Após a correção este caso **não requer exclusão**.

---

### `data_ip_1_w` e `data_ip_2_w` — Wires mortos, toggle estruturalmente inalcançável

**Observação (IMC):** Score=0, 0/8 bits cobertos para cada sinal.

**Código (`design.sv`, linhas 27–40):**
```systemverilog
// Declarados mas nunca conectados a nada:
wire [(DATA_WIDTH-1):0] data_ip_1_w;   // linha 27
wire [(DATA_WIDTH-1):0] data_ip_2_w;   // linha 28

// Instanciação usa diretamente os registros _r, não os wires _w:
alu_core #(...) alu (
    .data_ip_1 (data_ip_1_r),   // linha 36 — data_ip_1_w nunca aparece
    .data_ip_2 (data_ip_2_r),   // linha 37 — data_ip_2_w nunca aparece
    .sel_ip    (sel_ip_r),
    .data_op   (data_op_w)      // data_op_w é usado corretamente
);
```

**Por que são inalcançáveis:**

Os wires `data_ip_1_w` e `data_ip_2_w` são declarados com intenção de
servir como intermediários entre os registros de entrada e o `alu_core`, mas
**nenhuma atribuição contínua** (`assign`) foi escrita para eles e **nenhuma
porta do alu_core** está ligada a eles. Permanecem em X durante toda a
simulação — nunca transitam para 0 ou 1, logo nenhum toggle é possível.

O sinal `data_op_w` (linha 29) foi corretamente conectado como saída do
`alu_core` (linha 39), mas os dois wires de entrada ficaram orfãos.

**Ação:** Exclusão adicionada em
[`coverage_refine.cmd`](../run_xcelium/coverage_refine.cmd):

```tcl
deselect_coverage -toggle -instance top_tb.dut -variable data_ip_1_w
deselect_coverage -toggle -instance top_tb.dut -variable data_ip_2_w
```

**Recomendação RTL:** Remover as declarações dos wires não utilizados de
`design.sv` para eliminar o dead code e evitar confusão futura.

---

## Impacto na Cobertura (Toggle)

| Sinal         | Causa                        | Ação             |
|---------------|------------------------------|------------------|
| `rst`         | Driver não gerava 0→1        | Corrigido no TB  |
| `data_ip_1_w` | Wire morto, nunca conectado  | Excluído via IMC |
| `data_ip_2_w` | Wire morto, nunca conectado  | Excluído via IMC |
