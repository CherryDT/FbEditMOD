
/*
!!! Primary linker script file generated automatically !!!
This file contains the input and output files names
It also includes the secondary/main linker script that is specified in the Ride options (default or custom)
*/

SEARCH_DIR(".")
SEARCH_DIR("D:\STM32\Projects\FrequencyCounter")
SEARCH_DIR("D:\Ride\Ride\Lib\ARM")
STARTUP("startup_stm32f10x_md.o")
INPUT("D:\STM32\Projects\FrequencyCounter\main.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_it.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_tim.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_gpio.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_rcc.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_nvic.o")
INPUT("D:\STM32\Projects\FrequencyCounter\stm32f10x_flash.o")
EXTERN( __io_putchar )
EXTERN( _write )
GROUP(
"STM32x_io_putchar_thumb.a"
"std_sbrk_thumb.lib"
"smallprintf_thumb.a"
"libc.a"
"libm.a"

)
INCLUDE "D:\STM32\Projects\FrequencyCounter\STM32F100_64K_8K_FLASH.ld"
OUTPUT("D:\STM32\Projects\FrequencyCounter\FrequenctCounter.elf")
