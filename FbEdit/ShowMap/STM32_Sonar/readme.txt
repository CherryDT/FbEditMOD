/*******************************************************************************
* File Name          : readme.txt
* Author             : KetilO
* Version            : V1.0.0
* Date               : 05/13/2011
* Description        : Description of the sonar project.
*******************************************************************************/

Description
===========
A short ping at 200 KHz is transmitted at intervals depending on depth range (200 to 700 ms).
From the time it takes for the echo to return we can calculate the depth.
The ADC measures the strenght of the echo at intervalls depending on range
and stores it in a 512 byte array.

Speed of sound in water
=======================
Temp (C)    Speed (m/s)
  0             1403
  5             1427
 10             1447
 20             1481
 30             1507
 40             1526

1450 m/s is probably a good estimate.
Time for sound to travel 100 cm: 1000000 / 1450 = 689,66 ~ 690 us
Since it is the echo we are measuring: 690 * 2 = 1380 us

Two timers are needed:
1. A timer to generate the 200 KHz two phase non overlapping clock to drive the ping
   output signal. The number of pulses is variable (1 to 128). When the ping is done
   the timer is disabled and a second timer and the ADC channel reading the echo is
   enabled.
2. A timer to generate an interrupt for every pixel. The interval depends on range.
   In the interrupt handler the index of the echo array is incremented. At the same
   time the gain level DAC is updated with the value from the gain array, thus creating
   a time dependant gain control. A loop in main constantly reads the ADC echo and stores
   the largest reading in the echo array. This way a simple diode AM demodulator can be used.
   When the echo index reaches 512 the variable STM32_Sonar.Start is reset. This signals
   the loop in main to terminate and disable the timer and the ADC.


Time needed for the different ranges:
=========================================================================================================
Range		Time for echo to return		Pixel time					      cm / Pixel						            Pixel Timer
=========================================================================================================
  2 m		1380 *   2 =   2760 us		  2760 / 512 =    5,4 us	   5,4 / 1380 * 100 =  0,39 cm		  215
  4 m		1380 *   4 =   5520 us		  5520 / 512 =   10,8 us	  10,8 / 1380 * 100 =  0,78 cm		  430
  6 m		1380 *   6 =   8280 us		  8280 / 512 =   16,1 us	  16,1 / 1380 * 100 =  1.17 cm		  646
  8 m		1380 *   8 =  11040 us		  8280 / 512 =   21,6 us	  21,6 / 1380 * 100 =  1.56 cm		  861
 10 m		1380 *  10 =  13800 us		 13800 / 512 =   27,0 us	  27,0 / 1380 * 100 =  1.96 cm		 1077
 14 m		1380 *  14 =  19320 us		 19320 / 512 =   37,7 us	  37,7 / 1380 * 100 =  2,73 cm		 1508
 20 m		1380 *  20 =  27600 us		 27600 / 512 =   53,9 us	  53,9 / 1380 * 100 =  3,91 cm		 2154
 30 m		1380 *  30 =  41400 us		 41400 / 512 =   80,0 us	  80,0 / 1380 * 100 =  5,80 cm		 3232
 40 m		1380 *  40 =  55200 us		 55200 / 512 =  107,8 us	 107,8 / 1380 * 100 =  7,81 cm		 4309
 50 m		1380 *  50 =  69000 us		 69000 / 512 =  134,8 us	 134,8 / 1380 * 100 =  9,77 cm		 5387
 70 m		1380 *  70 =  96600 us		 96600 / 512 =  188,7 us	 188,7 / 1380 * 100 = 13,67 cm		 7542
100 m		1380 * 100 = 138000 us		138000 / 512 =  269,5 us	 269,5 / 1380 * 100 = 19,53 cm		10775
120 m		1380 * 120 = 165600 us		165600 / 512 =  323,4 us	 323,4 / 1380 * 100 = 23,44 cm		12930
150 m		1380 * 150 = 207000 us		207000 / 512 =  404,3 us	 404,3 / 1380 * 100 = 29,30 cm		16163
200 m		1380 * 200 = 276000 us		276000 / 512 =  539,1 us	 539,1 / 1380 * 100 = 39,07 cm		21551
250 m		1380 * 250 = 345000 us		345000 / 512 =  673,8 us	 673,8 / 1380 * 100 = 48,83 cm		26939
300 m		1380 * 300 = 414000 us		414000 / 512 =  808,6 us	 808,6 / 1380 * 100 = 58,59 cm		32327
350 m		1380 * 350 = 483000 us		483000 / 512 =  943,4 us	 943,4 / 1380 * 100 = 68,36 cm		37715
400 m		1380 * 400 = 552000 us		552000 / 512 = 1078,1 us	1078,1 / 1380 * 100 = 78,13 cm		43102
500 m		1380 * 500 = 690000 us		690000 / 512 = 1347,7 us	1347,7 / 1380 * 100 = 97,66 cm		53878
=========================================================================================================


Hardware environment
====================
Runs on STM32 Discovery.

Additional hardware
===================
o Transmitter capable of delivering at least 150 watts RMS to the swinger.
  For the swinger I am using, 1000 Vpp is needed.
o Echo receiver with gain control, tuned at 200 KHz.

Port pins used
==============
PA2		ADC Echo in
PA3		ADC Battery in
PA4		DAC channel1 Gain control out
PA5		ADC Water temprature in
PA6		ADC Air temprature in

PA8		Ping phase 0 out
PA9		Ping phase 1 out


Directory contents
==================
stm32f10x_conf.h  Library Configuration file
stm32f10x_it.c    Interrupt handlers
stm32f10x_it.h    Interrupt handlers header file
main.c            Main program
 

How to use it
=============
In order to make the program work, you must do the following:
- Create a project and setup all your toolchain's start-up files
- Compile the directory content files and required Library files:
  + stm32f10x_adc.c
  + stm32f10x_dac.c
  + stm32f10x_lib.c
  + stm32f10x_tim.c
  + stm32f10x_gpio.c
  + stm32f10x_rcc.c
  + stm32f10x_nvic.c
  + stm32ff10x_flash.c

- Link all compiled files and load your image into target memory
- Run the example
