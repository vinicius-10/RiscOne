/*
 * @file crt0.S
 * @brief Codigo de partida: executado a partir do PC = 0 apos o reset.
 *
 * 1. Inicializa a pilha no topo da DMEM.
 * 2. Zera a .bss.
 * 3. Chama main().
 * 4. Guarda o retorno de main em a0 (x10) e para em _halt (laco infinito).
 *    O tb_program detecta _halt (PC parado) e le a0 pela hierarquia.
 *
 * Limitacao: o reset do core zera so o PC. A .data NAO e recarregada apos
 * um reset na placa (ela so vem do data.mem na carga do FPGA); variaveis
 * globais inicializadas mantem o valor que tinham antes do reset.
 */
    .section .text.start, "ax"
    .globl _start
_start:
    la      sp, __stack_top

    la      t0, __bss_start
    la      t1, __bss_end
1:  bgeu    t0, t1, 2f
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       1b
2:
    call    main

    .globl _halt
_halt:
    j       _halt
