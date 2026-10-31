/*
 * @file main.S
 * @brief Exemplo de programa em assembly RV32I para o core (modelo da skill rv32i-programas).
 *
 * Soma um vetor da .data com uma funcao folha, testa load de byte com e sem
 * sinal, multiplica por software (RV32I nao tem MUL) e escreve nos LEDs.
 * Retorna 0 em a0 se tudo deu certo; senao, o numero do teste que falhou.
 *
 * Roda no simulador com: .\scripts\run_tb.ps1 tb_program -App asm_exemplo
 */
    .equ LEDS, 0x40000000

    .section .data
    .balign 4
vetor:      .word 3, 7, -2, 12          # soma = 20
n_vetor:    .word 4
bytes:      .byte 0x80, 0x7F            # lb -> -128, lbu -> 128

    .section .text
    .globl main
/* int main(void) -- nao-folha: salva ra e s0 na pilha (16 bytes, alinhada). */
main:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      s0, 8(sp)

    /* Teste 1: soma do vetor (chamada com argumentos em a0/a1) */
    la      a0, vetor
    lw      a1, n_vetor                 # pseudo: auipc + lw (dado na DMEM)
    call    soma                        # pseudo: auipc ra + jalr
    li      t0, 20
    li      s0, 1
    bne     a0, t0, falhou

    /* Teste 2: lb estende o sinal, lbu estende com zero */
    la      t1, bytes
    lb      t2, 0(t1)
    li      t0, -128
    li      s0, 2
    bne     t2, t0, falhou
    lbu     t2, 0(t1)
    li      t0, 128
    bne     t2, t0, falhou

    /* Teste 3: multiplicacao por software: 1234 * 56 = 69104 */
    li      a0, 1234
    li      a1, 56
    call    mul_sw
    li      t0, 69104                   # pseudo: lui + addi
    li      s0, 3
    bne     a0, t0, falhou

    /* Sucesso: LEDs = 0xA5A5, retorna 0 */
    li      t0, LEDS
    li      t1, 0xA5A5
    sw      t1, 0(t0)
    li      a0, 0
    j       fim

falhou:
    li      t0, LEDS
    li      t1, 0xE000
    or      t1, t1, s0
    sw      t1, 0(t0)
    mv      a0, s0                      # numero do teste que falhou

fim:
    lw      s0, 8(sp)
    lw      ra, 12(sp)
    addi    sp, sp, 16
    ret                                 # volta para o crt0, que para em _halt

/* int soma(const int *v, int n) -- folha: so usa registradores t/a. */
soma:
    li      t0, 0
1:  beqz    a1, 2f
    lw      t1, 0(a0)
    add     t0, t0, t1
    addi    a0, a0, 4
    addi    a1, a1, -1
    j       1b
2:  mv      a0, t0
    ret

/* unsigned mul_sw(unsigned a, unsigned b) -- shift-and-add. */
mul_sw:
    li      t0, 0
1:  beqz    a1, 2f
    andi    t1, a1, 1
    beqz    t1, 3f
    add     t0, t0, a0
3:  slli    a0, a0, 1
    srli    a1, a1, 1
    j       1b
2:  mv      a0, t0
    ret
