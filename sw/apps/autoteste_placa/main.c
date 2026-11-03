/**
 * @file main.c
 * @brief Autoteste para a placa: copia do selftest que usa as 37 instrucoes do RV32I.
 *
 * Retorna 0 se tudo passou; senao, retorna o numero do primeiro grupo que
 * falhou (o crt0 deixa o retorno em a0 e para em _halt). Tambem escreve o
 * resultado nos LEDs: 0xA5A5 = passou, 0xE000 | grupo = falhou. O botao de
 * reset (CPU_RESETN) roda o teste de novo.
 *
 * O grupo 11 usa assembly inline para as instrucoes que o GCC nao gera nos
 * grupos em C (LB, SLTI, SLTIU, XORI, ORI, SLT, SLTU, SRL, SRA, AND). Assim a
 * IMEM contem todas as instrucoes e a sintese mede o processador completo.
 *
 * As entradas vem de variaveis volatile para o GCC nao resolver as contas em
 * tempo de compilacao: assim o codigo gerado exercita de fato o hardware.
 */
#include <stdint.h>
#include "mmio.h"

/* .data (valor inicial vem do data.mem) */
volatile int32_t  g_a = -7;
volatile int32_t  g_b = 3;
volatile uint32_t g_big = 0x80000001u;
volatile uint32_t g_word = 0x11223344u;   /* testa a ordem dos bytes no data.mem */
volatile int8_t   g_bytes[4] = { -1, 2, -128, 127 };
volatile int16_t  g_halves[2] = { -2, 0x1234 };

/* .bss (zerada pelo crt0) */
volatile uint32_t g_zero[8];

/* .rodata (constantes na DMEM). volatile para o GCC ler da memoria em vez de
 * dobrar os valores em tempo de compilacao. */
static const volatile uint16_t k_table[6] = { 1, 1, 2, 3, 5, 8 };
static const volatile char k_str[] = "RV32I";

static __attribute__((noinline)) uint32_t fib(uint32_t n)
{
    return n < 2 ? n : fib(n - 1) + fib(n - 2);   /* recursao: pilha + JAL/JALR */
}

static __attribute__((noinline)) int classify(int x)
{
    /* Valores irregulares: o GCC monta uma tabela de consulta na .rodata
     * (lida com LW da DMEM) em vez de uma formula. */
    switch (x) {
    case 0: return 10;
    case 1: return 97;
    case 2: return 3;
    case 3: return 43;
    case 4: return 250;
    case 5: return 7;
    case 6: return 1234;
    default: return -1;
    }
}

static int add_op(int a, int b) { return a + b; }
static int sub_op(int a, int b) { return a - b; }
/* Ponteiros de funcao guardados na DMEM: o valor lido vira alvo de JALR. */
static int (*const volatile k_ops[2])(int, int) = { add_op, sub_op };

struct pair { int32_t x; int32_t y; uint8_t tag; };

#define CHECK(group, cond) do { if (!(cond)) return (group); } while (0)

/* Forcam uma instrucao especifica (o GCC nao reescreve assembly inline). */
#define ASM_RR(op, a, b) ({ int32_t r_; \
    __asm__ volatile (op " %0, %1, %2" : "=r"(r_) : "r"(a), "r"(b)); r_; })
#define ASM_RI(op, a, imm) ({ int32_t r_; \
    __asm__ volatile (op " %0, %1, %2" : "=r"(r_) : "r"(a), "i"(imm)); r_; })
#define ASM_LB(ptr, off) ({ int32_t r_; \
    __asm__ volatile ("lb %0, %1(%2)" : "=r"(r_) : "i"(off), "r"(ptr) : "memory"); r_; })

static int run_tests(void)
{
    int32_t a = g_a, b = g_b;
    uint32_t big = g_big;

    /* 1: aritmetica e logica */
    CHECK(1, a + b == -4);
    CHECK(1, a - b == -10);
    CHECK(1, (a & 0xFF) == 0xF9 && (a | b) == -5 && (a ^ b) == -6);

    /* 2: deslocamentos (logico vs aritmetico) */
    CHECK(2, (big >> 4) == 0x08000000u);
    CHECK(2, ((int32_t)big >> 4) == (int32_t)0xF8000000);
    CHECK(2, (big << 1) == 0x00000002u);
    CHECK(2, ((uint32_t)b << (b + 28)) == 0x80000000u);

    /* 3: comparacoes com e sem sinal */
    CHECK(3, a < b);
    CHECK(3, !((uint32_t)a < (uint32_t)b));
    CHECK(3, (int32_t)big < 0 && big > 1u);

    /* 4: multiplicacao e divisao via libgcc (__mulsi3, __divsi3, ...) */
    CHECK(4, a * b == -21);
    CHECK(4, a / b == -2 && a % b == -1);
    CHECK(4, big / 3u == 0x2AAAAAABu && big % 3u == 0u);

    /* 5: .data inicializada e ordem dos bytes (little-endian) */
    CHECK(5, g_word == 0x11223344u);
    CHECK(5, ((volatile uint8_t *)&g_word)[0] == 0x44);
    CHECK(5, ((volatile uint8_t *)&g_word)[3] == 0x11);

    /* 6: loads/stores de byte e halfword com e sem sinal */
    CHECK(6, g_bytes[0] == -1 && g_bytes[2] == -128 && g_bytes[3] == 127);
    CHECK(6, ((volatile uint8_t *)g_bytes)[0] == 0xFF);
    CHECK(6, g_halves[0] == -2 && ((volatile uint16_t *)g_halves)[0] == 0xFFFEu);
    g_bytes[1] = -3;
    g_halves[1] = (int16_t)0x8001;
    CHECK(6, g_bytes[1] == -3 && g_bytes[0] == -1 && g_bytes[2] == -128);
    CHECK(6, g_halves[1] == (int16_t)0x8001 && g_halves[0] == -2);

    /* 7: .bss zerada */
    for (int i = 0; i < 8; i++) CHECK(7, g_zero[i] == 0);

    /* 8: .rodata (tabela e string) */
    uint32_t sum = 0;
    for (int i = 0; i < 6; i++) sum += k_table[i];
    CHECK(8, sum == 20);
    CHECK(8, k_str[0] == 'R' && k_str[4] == 'I' && k_str[5] == '\0');

    /* 9: recursao, switch com tabela, ponteiro de funcao */
    CHECK(9, fib(g_b + 7) == 55);
    CHECK(9, classify(g_b) == 43 && classify(g_b + 3) == 1234 && classify(g_b + 10) == -1);
    CHECK(9, k_ops[0](a, b) == -4 && k_ops[1](a, b) == -10);

    /* 10: copia de struct (memcpy gerado pelo compilador) e laco com store */
    struct pair p = { a, b, 0x5A };
    volatile struct pair q;
    q = p;
    CHECK(10, q.x == -7 && q.y == 3 && q.tag == 0x5A);
    for (int i = 0; i < 8; i++) g_zero[i] = (uint32_t)i * 3u;
    CHECK(10, g_zero[7] == 21u);

    /* 11: instrucoes que o GCC nao gerou acima (a = -7, b = 3, big = 0x80000001) */
    CHECK(11, ASM_LB(g_bytes, 0) == -1 && ASM_LB(g_bytes, 2) == -128);
    CHECK(11, ASM_RI("slti", a, -6) == 1 && ASM_RI("slti", a, -7) == 0);
    CHECK(11, ASM_RI("sltiu", b, 4) == 1 && ASM_RI("sltiu", a, 4) == 0);
    CHECK(11, ASM_RI("xori", a, -1) == 6 && ASM_RI("ori", b, 0x40) == 0x43);
    CHECK(11, ASM_RR("slt", a, b) == 1 && ASM_RR("slt", b, a) == 0);
    CHECK(11, ASM_RR("sltu", a, b) == 0 && ASM_RR("sltu", b, a) == 1);
    CHECK(11, (uint32_t)ASM_RR("srl", big, b) == 0x10000000u);
    CHECK(11, (uint32_t)ASM_RR("sra", big, b) == 0xF0000000u);
    CHECK(11, ASM_RR("and", a, b) == 1);

    return 0;
}

int main(void)
{
    int r = run_tests();
    LEDS = r ? (0xE000u | (uint32_t)r) : 0xA5A5u;
    return r;
}
