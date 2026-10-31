/**
 * @file mmio.h
 * @brief Registradores de E/S mapeados em memoria (data_memory, addr[31:28] = 4).
 *
 * Ver docs/ESPEC_RV32I.md secao 9.
 */
#ifndef MMIO_H
#define MMIO_H

#include <stdint.h>

#define MMIO_REG(addr) (*(volatile uint32_t *)(addr))

#define LEDS      MMIO_REG(0x40000000u) /**< L/E: led[15:0] */
#define SWITCHES  MMIO_REG(0x40000004u) /**< L:   switch[15:0] */
#define BUTTONS   MMIO_REG(0x40000008u) /**< L:   {BTND, BTNR, BTNL, BTNU, BTNC} */
#define SEG7      MMIO_REG(0x4000000Cu) /**< L/E: [7:0] catodos, [15:8] anodos */
#define PMOD      MMIO_REG(0x40000010u) /**< L: linhas [3:0]; E: colunas [3:0] */

#define BTN_C (1u << 0)
#define BTN_U (1u << 1)
#define BTN_L (1u << 2)
#define BTN_R (1u << 3)
#define BTN_D (1u << 4)

#endif
