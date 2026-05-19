# UVM Testbench — ALU de 8 bits

Ambiente de verificação funcional para uma ALU (`alu_core`) de 8 bits, desenvolvido com **UVM (Universal Verification Methodology)** e simulado com o **Cadence Xcelium**.

## Operações suportadas

| `sel_ip` | Operação |
|----------|----------|
| `3'b000` | ADD  — soma |
| `3'b001` | SUB  — subtração |
| `3'b010` | MULT — multiplicação |
| `3'b011` | LSH  — shift lógico à esquerda |
| `3'b100` | RSH  — shift lógico à direita |
| `3'b101` | INCR — incremento (+1) |
| `3'b110` | DECR — decremento (−1) |
| `3'b111` | inválido (saída = 0) |

A saída (`data_op`) tem 16 bits para acomodar resultados de multiplicação.

## Estrutura do projeto

```
rtl/
  alu_core.sv      # ALU combinacional
  design.sv        # Wrapper registrado com sinais de handshake

uvm/
  alu_if.sv        # Interface SystemVerilog
  alu_pkg.sv       # Pacote UVM (inclui todos os componentes)
  testbench.sv     # Top-level: instancia DUT + interface, inicia teste
  objects/
    alu_tx.sv      # Sequence item (item de transação)
    alu_seq.sv     # Sequência de estímulos
  components/
    alu_agent.sv       # Agente UVM (driver + monitor + sequencer)
    alu_driver.sv      # Drive da interface
    alu_monitor.sv     # Amostragem da interface
    alu_scoreboard.sv  # Comparação com modelo de referência
    alu_cov_agent.sv   # Coleta de cobertura funcional
    alu_env.sv         # Ambiente UVM
    alu_test.sv        # Teste UVM

run_xcelium/
  run.sh           # Script de simulação
  refine.vRefine   # Refinamentos de cobertura (exclusões IMC)
```

## Pré-requisitos

- Cadence Xcelium 23.09 (ou compatível)
- IMC para análise de cobertura

## Como rodar

Todos os comandos devem ser executados a partir do diretório `run_xcelium/`:

```bash
cd run_xcelium

# Simulação padrão (seed fixo = 10, verbosidade UVM_MEDIUM)
./run.sh

# Controle de verbosidade
./run.sh UVM_FULL
./run.sh UVM_LOW
./run.sh UVM_NONE
```

Os dados de cobertura são gravados em `run_xcelium/cov_work/`.

## Visualizando cobertura

```bash
cd run_xcelium
imc -load cov_work/scope/
```

Para aplicar exclusões de branches estruturalmente inalcançáveis:

```
# Dentro da sessão interativa do IMC:
imc> load -refinement refine.vRefine
imc> save -refinement
```

Detalhes sobre as exclusões estão documentados em [docs/coverage_analysis.md](docs/coverage_analysis.md).
