/*
 * @file link.ld
 * @brief Script de linker para o RV32I monociclo (arquitetura Harvard).
 *
 * O processador tem duas memorias separadas, ambas comecando no endereco 0:
 *   IMEM: instruction_memory, so busca de instrucoes (loads NAO enxergam ela).
 *   DMEM: data_memory, RAM de dados (loads/stores, pilha).
 * Por isso .rodata (constantes, tabelas de switch, strings) vai para a DMEM,
 * nao para junto do codigo. Como as duas regioes se sobrepoem em endereco,
 * o link usa --no-check-sections (ver scripts/build_sw.ps1).
 *
 * Tamanhos: MEM_DEPTH = 1024 palavras => 4 KiB em cada memoria. Se mudar
 * MEM_DEPTH no core, ajuste LENGTH abaixo.
 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    DMEM (rw)  : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
    /* _start precisa ficar no endereco 0 (valor do PC apos o reset). */
    .text : {
        KEEP(*(.text.start))
        *(.text .text.*)
    } > IMEM

    /* Tudo que tem valor inicial vai para data.mem. */
    .rodata : {
        *(.srodata .srodata.*)
        *(.rodata .rodata.*)
    } > DMEM

    .data : {
        *(.sdata .sdata.*)
        *(.data .data.*)
    } > DMEM

    /* .bss nao entra no data.mem; o crt0 zera esta faixa. */
    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > DMEM

    /* Pilha cresce para baixo a partir do fim da DMEM. */
    __stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

    /DISCARD/ : { *(.comment) *(.note .note.*) *(.eh_frame*) }
}
