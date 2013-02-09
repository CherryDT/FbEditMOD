/*******************************************************************************
* File Name          : readme.txt
* Author             : KetilO
* Version            : V1.0.0
* Date               : 03/07/2011
* Description        : Description of the frequency counter demo project.
*******************************************************************************/

Example description
===================

This example shows how to use TIM peripherals to create a frequency counter.
In this example two timers are used:

1. TIM2 is configured as an event counter. Rising edges are counted on PA.01
2. TIM3 is used to create a 1000ms timebase.

Directory contents
==================
stm32f10x_conf.h  Library Configuration file
stm32f10x_it.c    Interrupt handlers
stm32f10x_it.h    Interrupt handlers header file
main.c            Main program
 

Hardware environment
====================
This example runs on STM32 Discovery.

- Connect the:
  - TIM2 CH2 (PA.01) pin to a function generator.
  The resolution is 1 Hz and max. frequency is 12MHz.
   
  
How to use it
=============
In order to make the program work, you must do the following:
- Create a project and setup all your toolchain's start-up files
- Compile the directory content files and required Library files:
  + stm32f10x_tim.c
  + stm32f10x_gpio.c
  + stm32f10x_rcc.c
  + stm32f10x_nvic.c
  + stm32ff10x_flash.c

- Link all compiled files and load your image into target memory
- Run the example
