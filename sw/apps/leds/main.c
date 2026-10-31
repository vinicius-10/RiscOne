/**
 * @file main.c
 * @brief Demo para a placa: LEDs seguem as chaves.
 *
 * - LEDs = chaves.
 * - Botao central (BTNC) segurado: LEDs mostram as chaves invertidas.
 * - Botao de cima (BTNU) segurado: LEDs mostram um contador que roda sozinho.
 */
#include <stdint.h>
#include "mmio.h"

int main(void)
{
    uint32_t counter = 0;

    for (;;) {
        uint32_t sw  = SWITCHES & 0xFFFFu;
        uint32_t btn = BUTTONS;

        if (btn & BTN_U)
            LEDS = (counter++ >> 12) & 0xFFFFu;   /* divide o contador para a contagem ficar visivel */
        else if (btn & BTN_C)
            LEDS = ~sw & 0xFFFFu;
        else
            LEDS = sw;
    }
}
