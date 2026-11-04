---
name: rv32i-programas
description: Use ao escrever, revisar ou depurar programas (C ou assembly .S) que rodam NESTE processador RV32I monociclo — sw/apps, crt0, link.ld, MMIO (LEDs, chaves, botões, 7 segmentos, PMOD), program_bytes.mem/data.mem, build_sw.ps1 ou tb_program. Também quando explicar o assembly gerado pelo riscv-gcc para este core. Não usar para alterar o RTL.
---

# Programas para o core RV32I deste projeto

O alvo é **RV32I puro, monociclo, Harvard, sem CSRs/traps**. Código que seria válido num RISC-V comum pode não funcionar aqui. Detalhes do hardware em `docs/ESPEC_RV32I.md`; decisões de escopo em `docs/DOCUMENTACAO_PROJETO.md` §8.

## 1. O que o hardware executa

- **Suportado (37):** LUI, AUIPC, JAL, JALR, BEQ/BNE/BLT/BGE/BLTU/BGEU, LB/LH/LW/LBU/LHU, SB/SH/SW, ADDI/SLTI/SLTIU/XORI/ORI/ANDI/SLLI/SRLI/SRAI, ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND.
- **Barrado pelo assembler** com `-march=rv32i` (erro de compilação, bom): `mul/div/rem` (M), `csrr/csrw/rdcycle` (Zicsr), `c.*` (C), `ld/sd`, atômicos (A), ponto flutuante (F/D).
- **Monta, mas vira NOP no core** (perigo: falha silenciosa): `ecall`, `ebreak`, `fence`, `fence.i`, e qualquer codificação inválida de funct3/funct7. Não use para syscalls/breakpoints/sincronização.
- **Sem trap de desalinhamento:** `lh/lw/sh/sw` em endereço não alinhado dá resultado errado sem aviso; alvo de salto com bit 1 = 1 também. Mantenha dados alinhados ao tamanho (`.balign 4` antes de `.word`, `.balign 2` antes de `.half`).
- Multiplicação/divisão em C funcionam via libgcc (`__mulsi3`, `__divsi3`...) — são lentas (dezenas a centenas de ciclos). Em assembly, faça shift-and-add (ver `sw/apps/asm_exemplo/main.S`).

## 2. Memória

| Faixa | O quê | Observação |
| :-- | :-- | :-- |
| IMEM `0x0000`–`0x0FFF` | instruções (`program_bytes.mem`) | **loads não leem a IMEM** |
| DMEM `0x0000`–`0x0FFF` | `.rodata`, `.data`, `.bss`, pilha (`data.mem`) | pilha começa em `0x1000` e desce |
| `0x4000_0000` | `IO_OUT(0)` = `LEDS` `[15:0]` | E (lê 0) |
| `0x4000_0004` | `IO_OUT(1)` = `SEG7`: `[7:0]` cátodos, `[15:8]` ânodos | E (lê 0) |
| `0x4000_0008` | `IO_OUT(2)` = `PMOD_COL`: colunas `[3:0]` | E (lê 0) |
| `0x4000_000C` | `IO_OUT(3)`: livre | E (lê 0) |
| `0x4000_0010` | `IO_IN(0)` = `SWITCHES` `[15:0]` | L |
| `0x4000_0014` | `IO_IN(1)` = `BUTTONS` `{BTND,BTNR,BTNL,BTNU,BTNC}` | L |
| `0x4000_0018` | `IO_IN(2)` = `PMOD_ROW`: linhas `[3:0]` | L |
| `0x4000_001C` | `IO_IN(3)`: livre (lê 0) | L |

- IMEM e DMEM começam ambas em 0 (Harvard). **Constantes, strings, tabelas de `switch` e de ponteiros de função precisam estar na DMEM** — o `sw/common/link.ld` já coloca `.rodata` lá. Em `.S`, nunca ponha dados em `.text` esperando lê-los com `lw`: declare-os em `.data` ou `.section .rodata`.
- 4 KiB por memória (`MEM_DEPTH = 1024`). O `build_sw.ps1` falha se o código passar de 4 KiB ou se dados+bss deixarem menos de 256 B para a pilha.
- Fora da RAM e fora do MMIO: leitura dá 0 e escrita é ignorada (sem erro).
- Os 8 registradores MMIO têm 32 bits. As saídas são **somente escrita**: ler `0x4000_0000`–`0x0C` devolve 0, então guarde o valor numa variável se precisar alterá-lo depois (ex.: acender um LED sem apagar os outros). Escrita em entrada é ignorada. O significado de cada um na placa vem do `top_core`; bits sem pino na placa são descartados pela síntese.
- Em C, use `sw/common/mmio.h` (`LEDS`, `SEG7`, `PMOD_COL`, `SWITCHES`, `BUTTONS`, `PMOD_ROW`, `BTN_*`, ou os genéricos `IO_OUT(n)`/`IO_IN(n)`). Acessos MMIO precisam de `volatile` (o header já faz). Programas compilados antes de 03/11/2026 usam o mapa antigo (chaves em `0x…04`): recompile.

## 3. Partida, retorno e reset

- `sw/common/crt0.S` roda a partir do PC = 0: `sp = 0x1000`, zera `.bss`, chama `main`, deixa o retorno em `a0` e para em `_halt` (`j .` = `0x0000006F`).
- Convenção de teste: `main` retorna **0 = sucesso**, outro valor = número do teste que falhou; por padrão também escrever nos LEDs `0xA5A5` (ok) ou `0xE000 | n` (falha), para ver na placa.
- Programa para a placa que nunca termina: `main` com laço infinito (ver `sw/apps/leds`).
- **O reset da placa zera só o PC.** `.data` não é recarregada (só vem do `data.mem` ao programar o FPGA); `.bss` é rezerada pelo crt0. Não dependa do valor inicial de globais após um reset — inicialize no `main` se precisar.

## 4. Fluxo

```powershell
# programa novo: crie sw/apps/<nome>/ com main.c ou main.S (pode misturar .c/.S)
powershell -ExecutionPolicy Bypass -File .\scripts\build_sw.ps1 <nome>          # -> build/sw/<nome>/
powershell -ExecutionPolicy Bypass -File .\scripts\run_tb.ps1 tb_program -App <nome>   # roda no core (xsim)
powershell -ExecutionPolicy Bypass -File .\scripts\build_sw.ps1 <nome> -Install # copia .mem p/ a síntese (pede ao usuário antes)
```

- Saídas em `build/sw/<nome>/`: `.lst` (disassembly intercalado com o C), `.map`, `program_bytes.mem` (instrução comentada por linha), `data.mem`.
- `tb_program` passa se `main` retornou 0; falha em timeout (200k ciclos), em instrução indefinida (salto para fora do programa) ou com `a0 ≠ 0`. Programas que nunca retornam (ex.: `leds`) dão timeout — isso é esperado; valide-os na placa.
- `-Install` sobrescreve os `.mem` usados pela síntese/GUI (faz backup em `build/sw/_backup/`). Só rode quando o usuário pedir.
- Para cobrir algo novo do hardware via C, acrescente um grupo em `sw/apps/selftest/main.c` (é o que o `run_tb.ps1` roda por padrão).

## 5. Armadilhas ao escrever C

- **O GCC resolve contas em tempo de compilação.** Entradas de teste devem vir de globais `volatile`, senão o código não exercita o hardware. Confira no `.lst` se as instruções esperadas aparecem.
- Tabelas `const` só vão parar na `.rodata` se forem lidas em tempo de execução (`const volatile` ou índice desconhecido).
- Sem libc: só `memcpy/memmove/memset/memcmp` (`sw/common/libc_min.c`). Nada de `printf`, `malloc`, `<stdio.h>`. Headers freestanding (`<stdint.h>`, `<stddef.h>`, `<stdbool.h>`) funcionam.
- Não há `gp`: compilado com `-msmall-data-limit=0`; endereços saem como `lui/addi` ou `auipc/addi`.

## 6. Modelo em assembly

Base: `sw/apps/asm_exemplo/main.S` (validado no `tb_program`). Estrutura mínima:

```asm
    .equ LEDS, 0x40000000

    .section .data
    .balign 4
valor:  .word 42

    .section .text
    .globl main
main:                       # chamado pelo crt0; sp já aponta para a DMEM
    addi    sp, sp, -16     # não-folha: salve ra e os s* usados (pilha alinhada em 16)
    sw      ra, 12(sp)

    lw      a0, valor       # pseudo: auipc + lw (dado na DMEM)
    li      t0, LEDS
    sw      a0, 0(t0)

    li      a0, 0           # 0 = sucesso
    lw      ra, 12(sp)
    addi    sp, sp, 16
    ret
```

- ABI: argumentos/retorno em `a0`–`a7`; `t*`/`a*` são do chamador; `s0`–`s11`, `sp` são do chamado (salvar/restaurar); `ra` deve ser salvo por funções não-folha. `x0` sempre lê 0.
- Pseudo-instruções seguras: `li`, `la`, `mv`, `j`, `call`, `ret`, `beqz`/`bnez`, `nop`, `not`, `neg`, `seqz`/`snez`, `bgt`/`ble`/`bgtu`/`bleu` (viram instruções RV32I).
- Verifique o resultado no `build/sw/<nome>/program_bytes.mem` (cada linha traz a instrução real).
