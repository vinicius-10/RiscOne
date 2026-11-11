/**
 * @file main.c
 * @brief Calculadora para a placa: soma, subtração, multiplicação e divisão
 *        de dois números com sinal (complemento de 2, 8 bits) lidos das chaves.
 *
 * Entrada:
 * - SW[15:8] = A e SW[7:0] = B, cada um de -128 a 127 (ex.: 1111_1111 = -1).
 *
 * Botões (a operação escolhida fica até apertar outro botão):
 * - BTNU = A + B    BTND = A - B    BTNL = A x B    BTNR = A / B
 * - BTNC = mostra os operandos (A nos 4 displays da esquerda, B nos 4 da direita).
 *   É o modo inicial.
 *
 * Saída:
 * - Resultado em decimal nos 7 displays da direita; o display da esquerda (o 8º)
 *   mostra "-" quando o resultado é negativo. Divisão por zero mostra "Err".
 * - A divisão trunca para zero, como em C (-7 / 2 = -3).
 * - LEDs = resultado em binário (16 bits, complemento de 2); no modo operandos, as chaves.
 *
 * O programa nunca retorna: no tb_program dá timeout (esperado), valide na placa.
 */
#include <stdint.h>
#include "mmio.h"

/* Segmentos ativos em 1, bit 0 = a ... bit 6 = g (a placa usa nível 0: inverte na escrita). */
static const uint8_t DIGITOS[10] = {
    0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
};
#define SEG_APAGADO 0x00
#define SEG_MENOS   0x40
#define SEG_E       0x79
#define SEG_R       0x50

/* Iterações da espera por dígito (~0,5 ms a 100 MHz): 8 dígitos ~ 250 Hz de varredura. */
#define ESPERA_DIGITO 8000u

enum operacao { OP_VER, OP_SOMA, OP_SUB, OP_MUL, OP_DIV };

static uint8_t tela[8];   /**< tela[0] = display da direita (an[0]), tela[7] = da esquerda */

/**
 * @brief Escreve v em decimal nos displays tela[base .. base+largura-1].
 * @param v       valor com sinal
 * @param base    primeiro display (o da direita do campo)
 * @param largura displays do campo: largura-1 dígitos alinhados à direita e,
 *                no display mais à esquerda do campo, o "-" se v < 0
 */
static void escreve_numero(int32_t v, int base, int largura)
{
    uint32_t m = (v < 0) ? -(uint32_t)v : (uint32_t)v;

    for (int i = 0; i < largura - 1; i++) {
        tela[base + i] = (i == 0 || m != 0) ? DIGITOS[m % 10u] : SEG_APAGADO;
        m /= 10u;
    }
    tela[base + largura - 1] = (v < 0) ? SEG_MENOS : SEG_APAGADO;
}

/** @brief Mostra "Err" nos displays da direita. */
static void escreve_erro(void)
{
    for (int i = 0; i < 8; i++)
        tela[i] = SEG_APAGADO;
    tela[2] = SEG_E;
    tela[1] = SEG_R;
    tela[0] = SEG_R;
}

/** @brief Espera ocupada (contador volatile para o GCC não remover o laço). */
static void espera(uint32_t n)
{
    for (volatile uint32_t i = 0; i < n; i++)
        ;
}

int main(void)
{
    enum operacao op = OP_VER;

    for (;;) {
        uint32_t sw  = SWITCHES;
        uint32_t btn = BUTTONS;

        if (btn & BTN_C)      op = OP_VER;
        else if (btn & BTN_U) op = OP_SOMA;
        else if (btn & BTN_D) op = OP_SUB;
        else if (btn & BTN_L) op = OP_MUL;
        else if (btn & BTN_R) op = OP_DIV;

        int32_t a = (int8_t)(sw >> 8);   /* extensão de sinal dos 8 bits */
        int32_t b = (int8_t)sw;
        int32_t r;

        if (op == OP_VER) {
            escreve_numero(a, 4, 4);
            escreve_numero(b, 0, 4);
            LEDS = sw & 0xFFFFu;
        } else if (op == OP_DIV && b == 0) {
            escreve_erro();
            LEDS = 0;
        } else {
            if (op == OP_SOMA)     r = a + b;
            else if (op == OP_SUB) r = a - b;
            else if (op == OP_MUL) r = a * b;   /* __mulsi3 da libgcc */
            else                   r = a / b;   /* __divsi3 da libgcc */
            escreve_numero(r, 0, 8);
            LEDS = (uint32_t)r & 0xFFFFu;
        }

        /* Varredura: um display aceso por vez (ânodos e cátodos ativos em 0). */
        for (int d = 0; d < 8; d++) {
            SEG7 = ((~(1u << d) & 0xFFu) << 8) | (~(uint32_t)tela[d] & 0xFFu);
            espera(ESPERA_DIGITO);
        }
    }
}
