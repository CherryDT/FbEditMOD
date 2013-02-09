
/*
!!! Primary linker script file generated automatically !!!
This file contains the input and output files names
It also includes the secondary/main linker script that is specified in the Ride options (default or custom)
*/

SEARCH_DIR(".")
SEARCH_DIR("D:\STM32\Projects\DDSWaveform")
SEARCH_DIR("D:\Ride\Ride\Lib\ARM")
STARTUP("\STM32\Projects\DDSWaveform\startup_stm32f10x_hd.o")
INPUT("D:\STM32\Projects\DDSWaveform\main.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_dac.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_gpio.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_it.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_lib.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_nvic.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_rcc.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_tim.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_adc.o")
INPUT("D:\STM32\Projects\DDSWaveform\stm32f10x_flash.o")
EXTERN( __io_putchar )
EXTERN( _write )
GROUP(
"STM32x_io_putchar_thumb.a"
"std_sbrk_thumb.lib"
"smallprintf_thumb.a"
"libc.a"
"libm.a"

)
INCLUDE "D:\STM32\Projects\DDSWaveform\STM32F100_64K_8K_FLASH.ld"
OUTPUT("D:\STM32\Projects\DDSWaveform\DDSWaveform.elf")
