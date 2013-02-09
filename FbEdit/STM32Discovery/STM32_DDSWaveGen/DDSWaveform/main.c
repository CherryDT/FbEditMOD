/*******************************************************************************
* File Name          : main.c
* Author             : KetilO
* Version            : V1.0.0
* Date               : 04/30/2011
* Description        : Main program body
********************************************************************************

/* Includes ------------------------------------------------------------------*/
#include "stm32f10x_lib.h"

/* Private define ------------------------------------------------------------*/
// Uncomment the clock speed you will be using
//#define STM32Clock24MHz
//#define STM32Clock28MHz
//#define STM32Clock32MHz
//#define STM32Clock40MHz
//#define STM32Clock48MHz
#define STM32Clock56MHz

/* STM32_Command */
#define STM32_CMNDWait            ((u8)0)
#define STM32_CMNDStart           ((u8)1)
#define STM32_CMNDFrqEnable       ((u8)2)

/* DDS SWEEP SubModes */
#define SWEEP_SubModeOff          ((u8)1)
#define SWEEP_SubModeUp           ((u8)2)
#define SWEEP_SubModeDown         ((u8)3)
#define SWEEP_SubModeUpDown       ((u8)4)
#define SWEEP_SubModePeak         ((u8)5)

typedef struct
{
  u32 Frequency;
  u32 PreviousCount;
  u32 Reserved1;
  u32 Reserved2;
}STM32_FRQTypeDef;

typedef struct
{
  STM32_FRQTypeDef STM32_Frequency;             // 0x20000000
  u8  cmnd;
  u8  HSC_enable;
  u16 HSC_div;
  u16 HSC_frq;
  u16 HSC_dutycycle;
  u32 DDS_PhaseFrq;                             // 0x20000018
  u8  DDS_SubMode;
  u8  DDS_DacBuffer;
  u16 SWEEP_StepTime;
  u32 SWEEP_UpDovn;                             // 0x20000020
  u32 SWEEP_Min;                                // 0x20000024
  u32 SWEEP_Max;                                // 0x20000028
  u32 SWEEP_Add;                                // 0x2000002C
  u16 Wave[2048];                               // 0x20000030
  u16 Peak[1536];                               // 0x20001030
}STM32_CMNDTypeDef;

/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
static STM32_CMNDTypeDef STM32_Command;         // 0x20000000

ErrorStatus HSEStartUpStatus;

/* Private function prototypes -----------------------------------------------*/
void RCC_Configuration(void);
void GPIO_Configuration(void);
void NVIC_Configuration(void);
void ADC_Startup(void);
void ADC_DVMConfiguration(void);
void TIM1_Configuration(void);
void TIM2_Configuration(void);
void TIM3_Configuration(void);
void TIM4_Configuration(void);
void DAC_DDS_Configuration(void);
void DDSWaveGenerator(void);
void DDSSweepWaveGenerator(void);
void DDSSweepWaveGeneratorPeak(void);

/* Private functions ---------------------------------------------------------*/

/*******************************************************************************
* Function Name  : main
* Description    : Main program
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
int main(void)
{
  u32 i;

  /* System clocks configuration ---------------------------------------------*/
  RCC_Configuration();
  /* NVIC configuration ------------------------------------------------------*/
  NVIC_Configuration();
  /* GPIO configuration ------------------------------------------------------*/
  GPIO_Configuration();
  /* TIM2 configuration ------------------------------------------------------*/
  TIM2_Configuration();
  /* TIM3 configuration ------------------------------------------------------*/
  TIM3_Configuration();
  /* TIM4 configuration ------------------------------------------------------*/
  TIM4_Configuration();
  /* ADC1 configuration ------------------------------------------------------*/
  ADC_Startup();
  /* ADC1 injected channels configuration ------------------------------------*/
  ADC_DVMConfiguration();

  while (1)
  {
    if (STM32_Command.cmnd == STM32_CMNDStart)
    {
      /* Reset STM32_CMNDStart */
      STM32_Command.cmnd = STM32_CMNDWait;
      /* Turn on LED4 */
      GPIO_SetBits(GPIOC,GPIO_Pin_8);
      /* DAC configuration */
      DAC_DDS_Configuration();
      /* Setup high speed clock */
      TIM1_Configuration();
      switch (STM32_Command.DDS_SubMode)
      {
        case SWEEP_SubModeOff:
          DDSWaveGenerator();
          break;
        case SWEEP_SubModeUp:
          DDSSweepWaveGenerator();
          break;
        case SWEEP_SubModeDown:
          DDSSweepWaveGenerator();
          break;
        case SWEEP_SubModeUpDown:
          DDSSweepWaveGenerator();
          break;
        case SWEEP_SubModePeak:
          DDSSweepWaveGeneratorPeak();
          break;
      }
    }
    else if (STM32_Command.cmnd == STM32_CMNDFrqEnable)
    {
      /* Reset STM32_CMNDFrqEnable */
      STM32_Command.cmnd = STM32_CMNDWait;
      /* Enable TIM2 */
      TIM_Cmd(TIM2, ENABLE);
      /* Enable TIM3 */
      TIM_Cmd(TIM3, ENABLE);
      /* Enable TIM4 */
      TIM_Cmd(TIM4, ENABLE);
      /* Enable TIM2 Update interrupt */
      TIM_ClearITPendingBit(TIM2,TIM_IT_Update);
      TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);
    }
    i=0;
    while (i < 100000)
    {
      i++;
    }
  }
}

/*******************************************************************************
* Function Name  : DAC_Configuration
* Description    : This function configures DAC for DDS wave generation
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DAC_DDS_Configuration(void)
{
  // /* DAC channel1 Configuration */
  if (STM32_Command.DDS_DacBuffer)
  {
    DAC->CR = 1;
  }
  else
  {
    DAC->CR = 3;
  }
}

/*******************************************************************************
* Function Name  : DDSWaveLoop
* Description    : This function generates the DDS waveform
*                  It updates the DAC every 8 cycles.
*                  With a 56MHz system clock the update
*                  frequency is 7MHz.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DDS_WaveLoop(void)
{
  while (1)
  {
    asm("mov    r5,r3,lsr #21");
    asm("ldrh   r5,[r1,r5,lsl #1]");
    asm("strh   r5,[r2,#0x0]");
    asm("add    r3,r3,r4");
  }
}

/*******************************************************************************
* Function Name  : DDSWaveGenerator
* Description    : This function generates a waveform using DDS
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DDSWaveGenerator(void)
{
  asm("movw   r1,#0x0030");
  asm("movt   r1,#0x2000");       /* STM32_Command.Wave[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */
  asm("movw   r4,#0x0018");
  asm("movt   r4,#0x2000");       /* STM32_Command.DDSPhaseFrq = 0x20000018 */
  asm("ldr    r4,[r4,#0x0]");     /* DDSPhaseFrq value */

  DDS_WaveLoop();
}

/*******************************************************************************
* Function Name  : DDSSweepWaveGenerator
* Description    : This function generates a sweep waveform using DDS
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DDSSweepWaveGenerator(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  NVIC_InitTypeDef NVIC_InitStructure;

  TIM_TimeBaseStructure.TIM_Period = STM32_Command.SWEEP_StepTime;
#ifdef STM32Clock24MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2399;
#endif
#ifdef STM32Clock28MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2799;
#endif
#ifdef STM32Clock32MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3199;
#endif
#ifdef STM32Clock40MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3999;
#endif
#ifdef STM32Clock48MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 4799;
#endif
#ifdef STM32Clock56MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 5599;
#endif
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM6, &TIM_TimeBaseStructure);
  TIM_InternalClockConfig(TIM6);
  /* Enable the TIM6 global Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM6_IRQChannel;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  /* TIM6 enable counter */
  TIM_Cmd(TIM6, ENABLE);
  TIM_ClearITPendingBit(TIM6,TIM_IT_Update);
  TIM_ITConfig(TIM6, TIM_IT_Update, ENABLE);

  /* Used by Clear TIM6 Update interrupt pending bit */
  asm("mov    r12,#0x0");
  asm("mov    r10,#0x1000");
  asm("movt   r10,#0x4000");
  asm("movt   r12,#0x0040");

  asm("movw   r9,#0x0800");
  asm("movt   r9,#0x4001");       /* GPIOA */
  asm("movw   r1,#0x0030");
  asm("movt   r1,#0x2000");       /* STM32_Command.Wave[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */

  asm("movw   r8,#0x0");          /* STM32_Command.SWEEP_UpDown = 0x20000020 */
  asm("movt   r8,#0x2000");
  asm("ldr    r0,[r8,#0x20]");    /* SWEEP up or down=0 / up and down=1 */
  asm("ldr    r6,[r8,#0x24]");    /* STM32_Command.SWEEP_Min = 0x20000024 */
  asm("ldr    r7,[r8,#0x28]");    /* STM32_Command.SWEEP_Max = 0x20000028 */
  asm("ldr    r8,[r8,#0x2C]");    /* STM32_Command.SWEEP_Add = 0x2000002C */
  asm("mov    r4,r6");            /* STM32_Command.SWEEP_Min */

  DDS_WaveLoop();
}

/*******************************************************************************
* Function Name  : TIM6_IRQHandler
* Description    : This function handles TIM6 global interrupt request.
*                  It is used by dds sweep
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM6_IRQHandler(void)
{
  /* Clear TIM6 Update interrupt pending bit */
  asm("strh   r9,[r10,#0x8 *2]");
  /* Clear sweep sync */
  asm("str    r12,[r9,#0x8 *2]");
  /* Prepare set sweep sync */
  asm("mov    r12,#0x0040");

  asm("cbnz   r0,lblupdown");
  /* Up or Down*/
  asm("add    r4,r8");            /* SWEEP_Add */
  asm("cmp    r4,r7");            /* SWEEP_Max */
  asm("itt     eq");              /* Make the next two instructions conditional */
  asm("moveq  r4,r6");            /* Conditional load SWEEP_Min */
  asm("streq  r12,[r9,#0x8 *2]"); /* Conditional set sweep sync */
  asm("bx     lr");               /* Return */

  /* Up & Down */
  asm("lblupdown:");
  asm("add    r4,r8");            /* SWEEP_Add */
  asm("cmp    r4,r7");            /* SWEEP_Max */
  asm("it     ne");               /* Make the next instruction conditional */
  asm("bxne   lr");               /*  Conditional return */
  /* Change direction */
  asm("mov    r11,r6");           /* tmp = SWEEP_Min */
  asm("mov    r6,r7");            /* SWEEP_Min = SWEEP_Max */
  asm("mov    r7,r11");           /* SWEEP_Max = tmp */
  asm("sub    r8,r9,r8");         /* Negate SWEEP_Add */
}

/*******************************************************************************
* Function Name  : DDSSweepWaveGeneratorPeak
* Description    : This function generates a sweep waveform using DDS
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DDSSweepWaveGeneratorPeak(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  NVIC_InitTypeDef NVIC_InitStructure;

  TIM_TimeBaseStructure.TIM_Period = STM32_Command.SWEEP_StepTime;
#ifdef STM32Clock24MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2399;
#endif
#ifdef STM32Clock28MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2799;
#endif
#ifdef STM32Clock32MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3199;
#endif
#ifdef STM32Clock40MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3999;
#endif
#ifdef STM32Clock48MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 4799;
#endif
#ifdef STM32Clock56MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 5599;
#endif
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM7, &TIM_TimeBaseStructure);
  TIM_InternalClockConfig(TIM7);
  /* Enable the TIM6 global Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM7_IRQChannel;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  /* TIM7 enable counter */
  TIM_Cmd(TIM7, ENABLE);
  TIM_ClearITPendingBit(TIM7,TIM_IT_Update);
  TIM_ITConfig(TIM7, TIM_IT_Update, ENABLE);

  /* Used by Clear TIM7 Update interrupt pending bit */
  asm("mov    r9,#0x0");
  asm("mov    r10,#0x1400");
  asm("movt   r10,#0x4000");

  asm("movw   r1,#0x0030");
  asm("movt   r1,#0x2000");       /* STM32_Command.Wave[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */

  asm("movw   r8,#0x0");
  asm("movt   r8,#0x2000");       /* Pointer to sweep init data */
  asm("ldr    r11,[r8,#0x24]");   /* SWEEP_Min */
  asm("ldr    r12,[r8,#0x28]");   /* SWEEP_Max */
  asm("ldr    r8,[r8,#0x2C]");    /* SWEEP_Add */
  asm("mov    r4,r11");           /* SWEEP_Min */
  asm("mov    r6,#0x30");         /* Peak index */

  DDS_WaveLoop();
}

/*******************************************************************************
* Function Name  : TIM7_IRQHandler
* Description    : This function handles TIM7 global interrupt request.
*                  It is used by dds sweep
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM7_IRQHandler(void)
{
  /* Clear TIM7 Update interrupt pending bit */
  asm("strh   r9,[r10,#0x8 *2]");

  /* Read injected channel 6, rank 3 */
  asm("mov    r0,#0x2400");
  asm("movt   r0,#0x4001");
  asm("ldrh   r7,[r0,#0x40]");    /* Get ADC injected value */
  asm("mov    r0,#0x1000");
  asm("movt   r0,#0x2000");       /* ADC value start address */
  asm("strh   r7,[r0,r6]");       /* Store value in ram */
  asm("add    r6,r6,#0x2");       /* Increment index */

  /* Up */
  asm("add    r4,r8");            /* SWEEP add */
  asm("cmp    r4,r12");           /* SWEEP max */
  asm("itt    eq");               /* Make the next 2 instructions conditional */
  asm("moveq  r4,r11");           /* Conditional load SWEEP min */
  asm("moveq  r6,#0x30");         /* Conditional reset index */
}

/*******************************************************************************
* Function Name  : TIM2_IRQHandler
* Description    : This function handles TIM2 global interrupt request.
*                  It calculates the frequency every 1000ms.
*                  Since it calculate the difference between this reading
*                  and the previous reading there is no need to take into
*                  account interrupt overhead.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM2_IRQHandler(void)
{
  /* Clear TIM2 Update interrupt pending bit */
  asm("mov    r1,#0x40000000");
  asm("strh   r1,[r1,#0x10]");
  /* Calculate frequency TIM3/TIM4 */
  asm("movw   r0,#0x0400");
  asm("movt   r0,#0x4000");         // TIM3
  asm("movw   r1,#0x0800");
  asm("movt   r1,#0x4000");         // TIM4
  asm("ldrh   r3,[r0,#0x24]");      // TIM3->CNT
  asm("ldrh   r2,[r1,#0x24]");      // TIM4->CNT
  asm("orr    r2,r3,r2,lsl #16");   // (TIM4->CNT << 16) | TIM2->CNT
  asm("mov    r1,#0x20000000");
  asm("ldr    r3,[r1,#0x4]");       // STM32_Frequency.PreviousCount
  asm("str    r2,[r1,#0x4]");       // STM32_Frequency.PreviousCount
  asm("sub    r2,r2,r3");
  asm("str    r2,[r1,#0x0]");       // STM32_Frequency.Frequency
}

/*******************************************************************************
* Function Name  : ADC_Startup
* Description    : This function calibrates ADC1.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void ADC_Startup(void)
{
  ADC_InitTypeDef ADC_InitStructure;
  /* ADCCLK = PCLK2/2 */
  RCC_ADCCLKConfig(RCC_PCLK2_Div2);
  /* ADC1 configuration ------------------------------------------------------*/
  ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;
  ADC_InitStructure.ADC_ScanConvMode = ENABLE;
  ADC_InitStructure.ADC_ContinuousConvMode = ENABLE;
  ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;
  ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;
  ADC_InitStructure.ADC_NbrOfChannel = 1;
  ADC_Init(ADC1, &ADC_InitStructure);
  /* ADC1 regular channel2 configuration */ 
  ADC_RegularChannelConfig(ADC1, ADC_Channel_2, 1, ADC_SampleTime_55Cycles5);
  /* Enable ADC1 */
  ADC_Cmd(ADC1, ENABLE);
  /* Enable ADC1 reset calibaration register */   
  ADC_ResetCalibration(ADC1);
  /* Check the end of ADC1 reset calibration register */
  while(ADC_GetResetCalibrationStatus(ADC1));
  /* Start ADC1 calibaration */
  ADC_StartCalibration(ADC1);
  /* Check the end of ADC1 calibration */
  while(ADC_GetCalibrationStatus(ADC1));
}

/*******************************************************************************
* Function Name  : ADC_DVNConfiguration
* Description    : This function prepares ADC1 for Injected conversion
*                  on channel 2 and channel 3.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void ADC_DVMConfiguration(void)
{
  ADC_InitTypeDef ADC_InitStructure;

  /* ADCCLK = PCLK2/8 */
  RCC_ADCCLKConfig(RCC_PCLK2_Div8);
  ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;
  ADC_InitStructure.ADC_ScanConvMode = ENABLE;
  ADC_InitStructure.ADC_ContinuousConvMode = ENABLE;
  ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;
  ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;
  /* ADC1 single channel configuration -----------------------------*/
  ADC_InitStructure.ADC_NbrOfChannel = 1;
  ADC_Init(ADC1, &ADC_InitStructure);

  ADC_InjectedSequencerLengthConfig(ADC1,2);
  ADC_InjectedChannelConfig(ADC1,ADC_Channel_2,1,ADC_SampleTime_239Cycles5);
  ADC_InjectedChannelConfig(ADC1,ADC_Channel_3,2,ADC_SampleTime_239Cycles5);
  ADC_AutoInjectedConvCmd(ADC1, ENABLE);
}

/*******************************************************************************
* Function Name  : RCC_Configuration
* Description    : Configures the different system clocks.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void RCC_Configuration(void)
{
  /* RCC system reset(for debug purpose) */
  RCC_DeInit();
  /* Enable HSE */
  RCC_HSEConfig(RCC_HSE_ON);
  /* Wait till HSE is ready */
  HSEStartUpStatus = RCC_WaitForHSEStartUp();
  if(HSEStartUpStatus == SUCCESS)
  {
    /* Enable Prefetch Buffer */
    FLASH_PrefetchBufferCmd(FLASH_PrefetchBuffer_Enable);
    /* Flash 2 wait state */
    FLASH_SetLatency(FLASH_Latency_0);
    /* HCLK = SYSCLK */
    RCC_HCLKConfig(RCC_SYSCLK_Div1); 
    /* PCLK2 = HCLK */
    RCC_PCLK2Config(RCC_HCLK_Div1); 
    /* PCLK1 = HCLK */
    RCC_PCLK1Config(RCC_HCLK_Div1);
    /* ADCCLK = PCLK2/2 */
    RCC_ADCCLKConfig(RCC_PCLK2_Div2);
#ifdef STM32Clock24MHz
    /* PLLCLK = 8MHz * 3 = 24 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_3);
#endif
#ifdef STM32Clock28MHz
    /* PLLCLK = 8MHz / 2 * 7 = 28 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div2, RCC_PLLMul_7);
#endif
#ifdef STM32Clock32MHz
    /* PLLCLK = 8MHz * 4 = 32 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_4);
#endif
#ifdef STM32Clock40MHz
    /* PLLCLK = 8MHz * 5 = 40 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_5);
#endif
#ifdef STM32Clock48MHz
    /* PLLCLK = 8MHz * 6 = 48 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_6);
#endif
#ifdef STM32Clock56MHz
    /* PLLCLK = 8MHz * 7 = 56 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_7);
#endif
    /* Enable PLL */ 
    RCC_PLLCmd(ENABLE);
    /* Wait till PLL is ready */
    while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET)
    {
    }
    /* Select PLL as system clock source */
    RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
    /* Wait till PLL is used as system clock source */
    while(RCC_GetSYSCLKSource() != 0x08)
    {
    }
  }
  /* Enable peripheral clocks ------------------------------------------------*/
  /* Enable TIM1, ADC1, GPIOA, GPIOB and GPIOC clock */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1 | RCC_APB2Periph_ADC1 | RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB | RCC_APB2Periph_GPIOC, ENABLE);
  /* Enable DAC, TIM2, TIM3, TIM4, TIM6 and TIM7 clock */
  RCC_APB1PeriphClockCmd(RCC_APB1Periph_DAC | RCC_APB1Periph_TIM2 | RCC_APB1Periph_TIM3 | RCC_APB1Periph_TIM4 | RCC_APB1Periph_TIM6 | RCC_APB1Periph_TIM7, ENABLE);
}

/*******************************************************************************
* Function Name  : GPIO_Configuration
* Description    : Configures the different GPIO ports.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void GPIO_Configuration(void)
{
  GPIO_InitTypeDef GPIO_InitStructure;
  /* Configure DAC Channel2 (PA.05), DAC Channel1 (PA.04), ADC Channel3 (PA.03) and ADC Channel2 (PA.02) as analog input */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_4 | GPIO_Pin_3 | GPIO_Pin_2;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* Configure PC.09 (LED3) and PC.08 (LED4) as output */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_8;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOC, &GPIO_InitStructure);
  /* TIM1 channel 1 pin (PA.08) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* TIM3 channel 2 pin (PA.07) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* Sweep sync pin (PA.06) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
}

/*******************************************************************************
* Function Name  : NVIC_Configuration
* Description    : Configures Vector Table base location.
*                  Configures interrupts.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;

  /* Set the Vector Table base location at 0x08000000 */ 
  NVIC_SetVectorTable(NVIC_VectTab_FLASH, 0x0);   
  /* Enable the TIM2 global Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM2_IRQChannel;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}

/*******************************************************************************
* Function Name  : TIM1_Configuration
* Description    : Configures TIM1 to generate PWM output on PA.08.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM1_Configuration(void)
{
  TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
  TIM_OCInitTypeDef  TIM_OCInitStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = STM32_Command.HSC_frq;
  TIM_TimeBaseStructure.TIM_Prescaler = STM32_Command.HSC_div;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseStructure.TIM_RepetitionCounter = 0;
  TIM_TimeBaseInit(TIM1, &TIM_TimeBaseStructure);
  /* PWM1 Mode configuration: Channel1 */
  TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;
  TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
  TIM_OCInitStructure.TIM_OutputNState = TIM_OutputState_Disable;
  TIM_OCInitStructure.TIM_Pulse = STM32_Command.HSC_dutycycle;
  TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
  TIM_OCInitStructure.TIM_OCNPolarity = TIM_OCPolarity_Low;
  TIM_OCInitStructure.TIM_OCIdleState = TIM_OCIdleState_Reset;
  TIM_OCInitStructure.TIM_OCNIdleState = TIM_OCIdleState_Reset;
  TIM_OC1Init(TIM1, &TIM_OCInitStructure);
  TIM_OC1PreloadConfig(TIM1, TIM_OCPreload_Enable);
  TIM_ARRPreloadConfig(TIM1, ENABLE);
  /* TIM1 Main Output Enable */
  TIM_CtrlPWMOutputs(TIM1, ENABLE);
  if (STM32_Command.HSC_enable)
  {
    /* TIM1 enable counter */
    TIM_Cmd(TIM1, ENABLE);
  }
}

/*******************************************************************************
* Function Name  : TIM2_Configuration
* Description    : Configures TIM2 to count up and generate interrupt every 1000ms.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM2_Configuration(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 9999;
#ifdef STM32Clock24MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2399;
#endif
#ifdef STM32Clock28MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 2799;
#endif
#ifdef STM32Clock32MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3199;
#endif
#ifdef STM32Clock40MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 3999;
#endif
#ifdef STM32Clock48MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 4799;
#endif
#ifdef STM32Clock56MHz
  TIM_TimeBaseStructure.TIM_Prescaler = 5599;
#endif
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM2, &TIM_TimeBaseStructure);
  TIM_InternalClockConfig(TIM2);
}

/*******************************************************************************
* Function Name  : TIM3_Configuration
* Description    : Configures TIM3 to count up on rising edges on CH2 PA.07
*                  TIM3 is master for TIM4.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM3_Configuration(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 0xffff;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM3, &TIM_TimeBaseStructure);
  TIM3->CCMR1 = 0x0100;     //CC2S=01
  TIM3->SMCR = 0x0067;      //TS=110, SMS=111
  /* Master Mode selection */
  TIM3->CR2 = 0x20;         //MMS=010
}

/*******************************************************************************
* Function Name  : TIM4_Configuration
* Description    : Configures TIM4 as a slave to TIM3 to form a 32bit up counter.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM4_Configuration(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 0xffff;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM4, &TIM_TimeBaseStructure);
  /* Slave Mode selection*/
  TIM4->SMCR = 0x0027;      //TS=010, SMS=111
}

/*****END OF FILE****/
