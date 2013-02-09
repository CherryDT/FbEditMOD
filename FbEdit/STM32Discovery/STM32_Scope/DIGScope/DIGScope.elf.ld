
/*
!!! Primary linker script file generated automatically !!!
This file contains the input and output files names
It also includes the secondary/main linker script that is specified in the Ride options (default or custom)
*/

SEARCH_DIR(".")
SEARCH_DIR("C:\STM32\Projects\DIGScope")
SEARCH_DIR("C:\Program Files\Raisonance\Ride\Lib\ARM")
STARTUP("\STM32\Projects\DIGScope\startup_stm32f10x_hd.o")
INPUT("C:\STM32\Projects\DIGScope\main.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_adc.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_dac.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_dma.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_flash.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_gpio.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_it.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_lib.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_nvic.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_rcc.o")
INPUT("C:\STM32\Projects\DIGScope\stm32f10x_tim.o")
EXTERN( __io_putchar )
EXTERN( _write )
GROUP(
"STM32x_io_putchar_thumb.a"
"std_sbrk_thumb.lib"
"smallprintf_thumb.a"
"libc.a"
"libm.a"

)
INCLUDE "C:\STM32\Projects\DIGScope\STM32F100_64K_8K_FLASH.ld"
OUTPUT("C:\STM32\Projects\DIGScope\DIGScope.elf")
