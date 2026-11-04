/**
 * @file mmio.h
 * @brief Registradores de E/S mapeados em memoria (data_memory, addr[31:28] = 4).
 *
 * O core tem 4 saidas genericas de 32 bits (out0..out3, somente escrita em
 * 0x4000_0000 + 4n; a leitura devolve 0)
 * e 4 entradas genericas de 32 bits (in0..in3, L em 0x4000_0010 + 4n). O que
 * cada uma liga na placa e definido no top_core. Ver docs/ESPEC_RV32I.md secao 9.
 */
#ifndef MMIO_H
#define MMIO_H

#include <stdint.h>

#define MMIO_REG(addr) (*(volatile uint32_t *)(addr))

#define IO_OUT(n) MMIO_REG(0x40000000u + 4u * (n)) /**< E (le 0): saida generica n (0..3) */
#define IO_IN(n)  MMIO_REG(0x40000010u + 4u * (n)) /**< L:   entrada generica n (0..3) */

/* Ligacoes da Nexys A7 no top_core */
#define LEDS      IO_OUT(0) /**< E (le 0): led[15:0] */
#define SEG7      IO_OUT(1) /**< E (le 0): [7:0] catodos, [15:8] anodos */
#define PMOD_COL  IO_OUT(2) /**< E (le 0): colunas do PMOD [3:0] */
#define SWITCHES  IO_IN(0)  /**< L:   switch[15:0] */
#define BUTTONS   IO_IN(1)  /**< L:   {BTND, BTNR, BTNL, BTNU, BTNC} */
#define PMOD_ROW  IO_IN(2)  /**< L:   linhas do PMOD [3:0] */

#define BTN_C (1u << 0)
#define BTN_U (1u << 1)
#define BTN_L (1u << 2)
#define BTN_R (1u << 3)
#define BTN_D (1u << 4)

#endif
