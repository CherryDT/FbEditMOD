/*******************************************************************************
* File Name          : main.c
* Author             : KetilO
* Version            : V1.0.0
* Date               : 03/19/2011
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

#define ADC1_DR_Address           ((u32)0x4001244C)
#define PC_IDR_Address            ((u32)0x40011008)
#define STM32_DataSize            ((u16)1024*7)
#define STM32_BlockSize           ((u8)64)

/* STM32_Command */
#define STM32_CommandWait         ((u8)0)
#define STM32_CommandInit         ((u8)1)
#define STM32_CommandSampleStart  ((u8)2)
#define STM32_CommandDone         ((u8)99)

/* STM32_Modes */
#define STM32_ModeNone            ((u8)0)
#define STM32_ModeScopeCHA        ((u8)1)
#define STM32_ModeScopeCHB        ((u8)2)
#define STM32_ModeScopeCHACHB     ((u8)3)
#define STM32_ModeWaveCHA         ((u8)4)
#define STM32_ModeWaveCHB         ((u8)5)
#define STM32_ModeWaveCHACHB      ((u8)6)
#define STM32_ModeLGA             ((u8)7)
#define STM32_ModeDDSWave         ((u8)8)
#define STM32_ModeWriteByte       ((u8)9)
#define STM32_ModeWriteHalfWord   ((u8)10)
#define STM32_ModeWriteWord       ((u8)11)
#define STM32_ModeReadByte        ((u8)12)
#define STM32_ModeReadHalfWord    ((u8)13)
#define STM32_ModeReadWord        ((u8)14)
#define STM32_ModeHSClockCHA      ((u8)15)
#define STM32_ModeHSClockCHB      ((u8)16)
#define STM32_ModeHSClockCHACHB   ((u8)17)

/* WAVE_SubModes */
#define WAVE_SubModeNoise         ((u8)0)
#define WAVE_SubModeTriangle      ((u8)1)
#define WAVE_SubModeWave          ((u8)2)

/* DDS SWEEP SubModes */
#define SWEEP_SubModeOff          ((u8)0)
#define SWEEP_SubModeUp           ((u8)1)
#define SWEEP_SubModeDown         ((u8)2)
#define SWEEP_SubModeUpDown       ((u8)3)
#define SWEEP_SubModePeak         ((u8)4)

/* STM32_Triggers */
#define STM32_TriggerManual       ((u8)0)
#define STM32_TriggerRisingCHA    ((u8)1)
#define STM32_TriggerFallingCHA   ((u8)2)
#define STM32_TriggerRisingCHB    ((u8)3)
#define STM32_TriggerFallingCHB   ((u8)4)
#define STM32_TriggerLGA          ((u8)5)

/* Private typedef -----------------------------------------------------------*/
typedef struct
{
  u8 STM32_Command;
  u8 STM32_Mode;
  u8 STM32_SampleRateL;
  u8 STM32_SampleRateH;
  union
  {
    struct
    {
      u8 STM32_DataBlocks;
      u8 STM32_TriggerMode;
      u8 ADC_TriggerValueCHA;
      u8 ADC_DCNullOutCHA;
    };
    u32 Address;
    u32 DDSPhaseFrq;                // 0x20000024
  };
  union
  {
    struct
    {
      u8 ADC_TriggerValueCHB;
      u8 ADC_DCNullOutCHB;
      u8 LGA_TriggerValue;
      u8 LGA_TriggerMask;
    };
    struct
    {
      u16 SWEEP_StepTime;
      u8 SWEEP_SubMode;
      u8 DDSDacBuffer;
    };
    u8 dByte;
    u16 dHalfWord;
    u32 dWord;
  };
  union
  {
    struct
    {
      u8 WAVE_SubModeCHA;
      u8 WAVE_SubModeCHB;
      u8 LGA_TriggerEdge;
      vu8 TIM3_TimeOut;
    };
    struct
    {
      u8 ADC_AmplifyCHA;
      u8 ADC_AmplifyCHB;
    };
  };
}STM32_CommandStructTypeDef;

typedef struct
{
  u32 Frequency;
  u32 PreviousCount;
  u32 Reserved;
  u16 DVM;
  u16 TIMxH;
}STM32_FRQDataStructTypeDef;

typedef struct
{
  STM32_FRQDataStructTypeDef STM32_FRQDataStructCHA;    // 0x20000000
  STM32_FRQDataStructTypeDef STM32_FRQDataStructCHB;    // 0x20000010
  STM32_CommandStructTypeDef STM32_CommandStruct;       // 0x20000020
  u8 STM32_Data[STM32_DataSize];                        // 0x20000030
}STM32_DataStructTypeDef;

/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
static STM32_DataStructTypeDef STM32_DataStruct;        // 0x20000000

ErrorStatus HSEStartUpStatus;

/* Private function prototypes -----------------------------------------------*/
void RCC_Configuration(void);
void GPIO_Configuration(void);
void NVIC_Configuration(void);
void ADC_Startup(void);
void ADC_Configuration(void);
void DMA_ADC_Configuration(void);
void DMA_LGA_Configuration(void);
void TIM1_Configuration(void);
void TIM2_Configuration(void);
void TIM3_Configuration(void);
void TIM4_Configuration(void);
void TIM6_Configuration(void);
void TIM7_Configuration(void);
void TIM15_Configuration(void);
void TIM16_Configuration(void);
void TIM17_Configuration(void);
void DAC_DDS_Configuration(void);
void DDSWaveGenerator(void);
void DDSSweepWaveGenerator(void);
void DDSSweepWaveGeneratorPeak(void);
void WaitForTrigger(void);
void FAST_LGA_Read(void);
void ADC_DVMConfiguration(void);

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
  u32 *adr;

  /* System clocks configuration ---------------------------------------------*/
  RCC_Configuration();
  /* NVIC configuration ------------------------------------------------------*/
  NVIC_Configuration();
  /* GPIO configuration ------------------------------------------------------*/
  GPIO_Configuration();
  /* TIM1 configuration ------------------------------------------------------*/
  TIM1_Configuration();
  /* TIM2 configuration ------------------------------------------------------*/
  TIM2_Configuration();
  /* TIM3 configuration ------------------------------------------------------*/
  TIM3_Configuration();
  /* TIM4 configuration ------------------------------------------------------*/
  TIM4_Configuration();
  /* TIM6 configuration ------------------------------------------------------*/
  TIM6_Configuration();
  /* TIM7 configuration ------------------------------------------------------*/
  TIM7_Configuration();
  /* TIM15 configuration -----------------------------------------------------*/
  TIM15_Configuration();
  /* TIM16 configuration -----------------------------------------------------*/
  TIM16_Configuration();
  /* TIM17 configuration -----------------------------------------------------*/
  TIM17_Configuration();
  /* ADC1 sartup -------------------------------------------------------------*/
  ADC_Startup();
  /* ADC1 injected channels configuration ------------------------------------*/
  ADC_DVMConfiguration();
  /* Enable TIM1 */
  TIM_Cmd(TIM1, ENABLE);
  /* Enable TIM2 */
  TIM_Cmd(TIM2, ENABLE);
  /* Enable TIM3 */
  TIM_Cmd(TIM3, ENABLE);
  /* Enable TIM4 */
  TIM_Cmd(TIM4, ENABLE);
  /* Enable TIM2 Update interrupt */
  TIM_ClearITPendingBit(TIM2,TIM_IT_Update);
  TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);
  /* Enable TIM3 Update interrupt */
  TIM_ClearITPendingBit(TIM3,TIM_IT_Update);
  TIM_ITConfig(TIM3, TIM_IT_Update, ENABLE);
  /* Enable TIM4 Update interrupt */
  TIM_ClearITPendingBit(TIM4,TIM_IT_Update);
  TIM_ITConfig(TIM4, TIM_IT_Update, ENABLE);

  while (1)
  {
    if (STM32_DataStruct.STM32_CommandStruct.STM32_Command == STM32_CommandInit)
    {
      /* Reset STM32_CommandInit */
      STM32_DataStruct.STM32_CommandStruct.STM32_Command = STM32_CommandWait;
      /* Turn on LED4 */
      GPIO_SetBits(GPIOC,GPIO_Pin_8);
      /* TIM1 disable counter */
      TIM_Cmd(TIM1, DISABLE);
      /* TIM1 reset count */
      TIM1->CNT = (u16)0;
      /* Set the TIM1 Capture Compare Register values */
      TIM1->CCR1 = (u16)STM32_DataStruct.STM32_CommandStruct.ADC_TriggerValueCHA;
      TIM1->CCR2 = (u16)STM32_DataStruct.STM32_CommandStruct.ADC_DCNullOutCHA;
      TIM1->CCR3 =  (u16)STM32_DataStruct.STM32_CommandStruct.ADC_TriggerValueCHB;
      TIM1->CCR4 =  (u16)STM32_DataStruct.STM32_CommandStruct.ADC_DCNullOutCHB;
      /* TIM1 enable counter */
      TIM_Cmd(TIM1, ENABLE);
      switch (STM32_DataStruct.STM32_CommandStruct.STM32_Mode)
      {
        case STM32_ModeScopeCHA...STM32_ModeScopeCHACHB:
          /* Set CHA and CHB Amplification levels */
          GPIOB->ODR = (u16)(GPIOB->ODR & 0x03FF) | ((STM32_DataStruct.STM32_CommandStruct.ADC_AmplifyCHB << 13) | (STM32_DataStruct.STM32_CommandStruct.ADC_AmplifyCHA << 10));
          /* DMA1 channel1 configuration -----------------------------------------*/
          DMA_ADC_Configuration();
          /* ADC1 configuration --------------------------------------------------*/
          ADC_Configuration();
          break;
        case STM32_ModeWaveCHA...STM32_ModeWaveCHACHB:
          break;
        case STM32_ModeLGA:
          /* TIM15 configuration ------------------------------------------------*/
          TIM15_Configuration();
          /* DMA1 channel5 configuration ----------------------------------------*/
          DMA_LGA_Configuration();
          break;
        case STM32_ModeDDSWave:
          ADC_DVMConfiguration();
          DAC_DDS_Configuration();
          switch ((u8) STM32_DataStruct.STM32_CommandStruct.SWEEP_SubMode)
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
          break;
        case STM32_ModeWriteByte:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          *adr = STM32_DataStruct.STM32_CommandStruct.dByte;
          break;
        case STM32_ModeWriteHalfWord:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          *adr = STM32_DataStruct.STM32_CommandStruct.dHalfWord;
          break;
        case STM32_ModeWriteWord:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          *adr = STM32_DataStruct.STM32_CommandStruct.dWord;
          break;
        case STM32_ModeReadByte:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          STM32_DataStruct.STM32_CommandStruct.dByte = *adr;
          break;
        case STM32_ModeReadHalfWord:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          STM32_DataStruct.STM32_CommandStruct.dHalfWord = *adr;
          break;
        case STM32_ModeReadWord:
          adr = (u32 *)STM32_DataStruct.STM32_CommandStruct.Address;
          STM32_DataStruct.STM32_CommandStruct.dWord = *adr;
          break;
      }
    }
    else if (STM32_DataStruct.STM32_CommandStruct.STM32_Command == STM32_CommandSampleStart)
    {
      /* Turn off LED4 */
      GPIO_ResetBits(GPIOC,GPIO_Pin_8);
      /* Turn on LED3 */
      GPIO_SetBits(GPIOC,GPIO_Pin_9);
      switch (STM32_DataStruct.STM32_CommandStruct.STM32_Mode)
      {
        case STM32_ModeScopeCHA:
          /* ADC1 regular channel 8 configuration */ 
          /* Set sample time for channel 8 */
          ADC1->SMPR2 = ((u32)STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL << 24);
          /* Set rank 1 for channel 8 */
          /* |00|Rank6|Rank5|Rank4|Rank3|Rank2|Rank1| */
          /* |00|00000|00000|00000|00000|00000|01000| */
          ADC1->SQR3 = (u32)0x00000008;
          /* Enable ADC1 DMA */
          ADC1->CR2 |=(u32)0x00000100;
          /* Enable ADC1 */
          ADC1->CR2 |= (u32)0x00000001;
          WaitForTrigger();
          /* Enable DMA1 channel1 */
          DMA1_Channel1->CCR |= (u32)0x00000001;
          /* Wait until DMA transfer complete */
          while ((DMA1->ISR && DMA1_FLAG_TC1) == 0)
          {
          }
          /* Disable DMA */
          DMA_Cmd(DMA1_Channel1, DISABLE);
          /* Disable ADC1 */
          ADC_SoftwareStartConvCmd(ADC1, DISABLE);
          break;
        case STM32_ModeScopeCHB:
          /* ADC1 regular channel 9 configuration */ 
          /* Set sample time for channel 9 */
          ADC1->SMPR2 = ((u32)STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL << 27);
          /* Set rank 1 for channel 9 */
          /* |00|Rank6|Rank5|Rank4|Rank3|Rank2|Rank1| */
          /* |00|00000|00000|00000|00000|00000|01001| */
          ADC1->SQR3 = (u32)0x00000009;
          /* Enable ADC1 DMA */
          ADC1->CR2 |=(u32)0x00000100;
          /* Enable ADC1 */
          ADC1->CR2 |= (u32)0x00000001;
          WaitForTrigger();
          /* Enable DMA1 channel1 */
          DMA1_Channel1->CCR |= (u32)0x00000001;
          /* Wait until DMA transfer complete */
          while ((DMA1->ISR && DMA1_FLAG_TC1) == 0)
          {
          }
          /* Disable DMA */
          DMA_Cmd(DMA1_Channel1, DISABLE);
          /* Disable ADC1 */
          ADC_SoftwareStartConvCmd(ADC1, DISABLE);
          break;
        case STM32_ModeScopeCHACHB:
          WaitForTrigger();
          /* ADC1 regular channel 8 and channel 9 configuration */ 
          /* Set sample time for channel 8 and channel 9 */
          ADC1->SMPR2 = (((u32)STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL << 24) | ((u32)STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL << 27));
          /* Set rank 2 for channel 8 and rank 1 for channel 9 */
          /* |00|Rank6|Rank5|Rank4|Rank3|Rank2|Rank1| */
          /* |00|00000|00000|00000|00000|01000|01001| */
          ADC1->SQR3 = (u32)0x00000109;
          /* Enable DMA1 channel1 */
          DMA1_Channel1->CCR |= (u32)0x00000001;
          /* Enable ADC1 DMA */
          ADC1->CR2 |=(u32)0x00000100;
          /* Enable ADC1 */
          ADC1->CR2 |= (u32)0x00000001;
          // /* Wait until DMA transfer complete */
          while ((DMA1->ISR && DMA1_FLAG_TC1) == 0)
          {
          }
          /* Disable DMA */
          DMA_Cmd(DMA1_Channel1, DISABLE);
          /* Disable ADC1 */
          ADC_SoftwareStartConvCmd(ADC1, DISABLE);
          break;
        case STM32_ModeWaveCHA:
          break;
        case STM32_ModeWaveCHB:
          break;
        case STM32_ModeWaveCHACHB:
          break;
        case STM32_ModeLGA:
          if ((STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateH << 8) + STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL == 0)
          {
            /* Wait for trigger */
            WaitForTrigger();
            FAST_LGA_Read();
          }
          else
          {
            /* Enable DMA1 channel5 */
            DMA1_Channel5->CCR |= (u32)0x00000001;
            /* Set TIM15 Counter */
            TIM_SetCounter(TIM15,(u16)(STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateH << 8) + STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL);
            /* Wait for trigger */
            WaitForTrigger();
            /* Enable TIM15 */
            TIM15->CR1 = (u16)0x0001;
            /* Wait until DMA transfer complete */
            while ((DMA1->ISR && DMA1_FLAG_TC5) == 0)
            {
            }
            /* Disable DMA */
            DMA_Cmd(DMA1_Channel5, DISABLE);
            /* Disable TIM15 */
            TIM_Cmd(TIM15, DISABLE);
          }
          break;
      }
      ADC_DVMConfiguration();
      /* Set sample ready to be read flag */
      STM32_DataStruct.STM32_CommandStruct.STM32_Command = STM32_CommandDone;
    }
    i=0;
    while (i < 10000)
    {
      i++;
    }
    /* Turn off LED3 */
    GPIO_ResetBits(GPIOC,GPIO_Pin_9);
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
  if ((u8) STM32_DataStruct.STM32_CommandStruct.DDSDacBuffer)
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
  asm("movt   r1,#0x2000");       /* STM32_DataStruct.STM32_CommandStruct.STM32_Data[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */
  asm("movw   r4,#0x0024");
  asm("movt   r4,#0x2000");       /* STM32_DataStruct.STM32_CommandStruct.DDSPhaseFrq = 0x20000024 */
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

  TIM_TimeBaseStructure.TIM_Period = STM32_DataStruct.STM32_CommandStruct.SWEEP_StepTime;
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
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 4;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  /* TIM6 enable counter */
  TIM_Cmd(TIM6, ENABLE);
  TIM_ClearITPendingBit(TIM6,TIM_IT_Update);
  TIM_ITConfig(TIM6, TIM_IT_Update, ENABLE);

  /* Used by Clear TIM6 Update interrupt pending bit */
  asm("mov    r9,#0x0");
  asm("mov    r10,#0x1000");
  asm("movt   r10,#0x4000");

  asm("movw   r1,#0x0030");
  asm("movt   r1,#0x2000");       /* STM32_DataStruct.STM32_CommandStruct.STM32_Data[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */

  asm("movw   r8,#0x1030");
  asm("movt   r8,#0x2000");
  asm("ldr    r0,[r8,#0x0]");     /* SWEEP up or down=0 / up and down=1 */
  asm("ldr    r6,[r8,#0x4]");     /* SWEEP min */
  asm("ldr    r7,[r8,#0x8]");     /* SWEEP max */
  asm("ldr    r8,[r8,#0xC]");     /* SWEEP add */
  asm("mov    r4,r6");            /* SWEEP min */

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

  asm("cbnz   r0,lblupdown");
  /* Up or Down*/
  asm("add    r4,r8");            /* SWEEP add */
  asm("cmp    r4,r7");            /* SWEEP max */
  asm("it     eq");               /* Make the next instruction conditional */
  asm("moveq  r4,r6");            /* Conditional load SWEEP min */
  asm("bx     lr");

  /* Up & Down */
  asm("lblupdown:");
  asm("add    r4,r8");            /* SWEEP add */
  asm("cmp    r4,r7");            /* SWEEP max */
  asm("it     ne");               /* Make the next instruction conditional */
  asm("bxne   lr");               /*  Conditional return */
  /* Change direction */
  asm("mov    r11,r6");           /* tmp = SWEEP min */
  asm("mov    r6,r7");            /* SWEEP min = SWEEP max */
  asm("mov    r7,r11");           /* SWEEP max = tmp */
  asm("sub    r8,r9,r8");         /* Negate SWEEP Add */
}

void DDSSweepWaveGeneratorPeak(void)
{
  ADC_InitTypeDef ADC_InitStructure;
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  NVIC_InitTypeDef NVIC_InitStructure;

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

  ADC_InjectedSequencerLengthConfig(ADC1,3);
  ADC_InjectedChannelConfig(ADC1,ADC_Channel_2,1,ADC_SampleTime_239Cycles5);
  ADC_InjectedChannelConfig(ADC1,ADC_Channel_3,2,ADC_SampleTime_239Cycles5);
  ADC_InjectedChannelConfig(ADC1,ADC_Channel_6,3,ADC_SampleTime_239Cycles5);
  ADC_AutoInjectedConvCmd(ADC1, ENABLE);

  TIM_TimeBaseStructure.TIM_Period = STM32_DataStruct.STM32_CommandStruct.SWEEP_StepTime;
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
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 5;
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
  asm("movt   r1,#0x2000");       /* STM32_DataStruct.STM32_CommandStruct.STM32_Data[0] = 0x20000030 */
  asm("movw   r2,#0x7408");
  asm("movt   r2,#0x4000");       /* DAC_DHR12R1 */
  asm("mov    r3,#0x0");          /* DDSPhase pointer value */

  asm("movw   r8,#0x1030");
  asm("movt   r8,#0x2000");       /* Pointer to sweep init data */
  asm("ldr    r11,[r8,#0x4]");    /* SWEEP min */
  asm("ldr    r12,[r8,#0x8]");    /* SWEEP max */
  asm("ldr    r8,[r8,#0xC]");     /* SWEEP add */
  asm("mov    r4,r11");           /* SWEEP min */
  asm("mov    r6,#0x0");

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
void TIM7_IRQHandler(void)
{
  /* Clear TIM7 Update interrupt pending bit */
  asm("strh   r9,[r10,#0x8 *2]");

  /* Read injected channel 6, rank 3 */
  asm("mov    r0,#0x2400");
  asm("movt   r0,#0x4001");
  asm("ldrh   r7,[r0,0x44]");     /* Get ADC injected value */
  asm("mov    r0,#0x1040");
  asm("movt   r0,#0x2000");       /* ADC value start address*/
  asm("strh   r7,[r0,r6]");       /* Store value in ram */
  asm("add    r6,r6,0x2");        /* Increment index */

  /* Up */
  asm("add    r4,r8");            /* SWEEP add */
  asm("cmp    r4,r12");           /* SWEEP max */
  asm("itt    eq");               /* Make the next 2 instructions conditional */
  asm("moveq  r4,r11");           /* Conditional load SWEEP min */
  asm("moveq  r6,#0x0");
}

/*******************************************************************************
* Function Name  : WaitForTrigger
* Description    : This function waits for a trigger on CHA, CHB or
*                  logic analyser .
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void WaitForTrigger(void)
{
  u16 tmp;
  /* Syncronize with rising or falling edge or logic analyser */
  switch (STM32_DataStruct.STM32_CommandStruct.STM32_TriggerMode)
  {
    case (STM32_TriggerRisingCHA):
      /* Count on rising edge */
      TIM2->CCER = 0x0000;
      /* Wait until TIM2 increments */
      tmp = TIM2->CNT;
      while (tmp == TIM2->CNT)
      {
        if (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut == 0)
        {
          break;
        }
      }
      break;
    case (STM32_TriggerFallingCHA):
      /* Count on falling edge */
      TIM2->CCER = 0x0022;
      /* Wait until TIM2 increments */
      tmp = TIM2->CNT;
      while (tmp == TIM2->CNT)
      {
        if (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut == 0)
        {
          break;
        }
      }
      break;
    case (STM32_TriggerRisingCHB):
      /* Count on rising edge */
      TIM4->CCER = 0x0000;
      /* Wait until TIM4 increments */
      tmp = TIM4->CNT;
      while (tmp == TIM4->CNT)
      {
        if (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut == 0)
        {
          break;
        }
      }
      break;
    case (STM32_TriggerFallingCHB):
      /* Count on falling edge */
      TIM4->CCER = 0x0022;
      /* Wait until TIM4 increments */
      tmp = TIM4->CNT;
      while (tmp == TIM4->CNT)
      {
        if (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut == 0)
        {
          break;
        }
      }
      break;
    case (STM32_TriggerLGA):
      tmp = STM32_DataStruct.STM32_CommandStruct.LGA_TriggerValue & STM32_DataStruct.STM32_CommandStruct.LGA_TriggerMask;
      if ((STM32_DataStruct.STM32_CommandStruct.LGA_TriggerEdge != 0) & (STM32_DataStruct.STM32_CommandStruct.LGA_TriggerMask != 0))
      {
        /* Edge sensitive */
        /* Wait while conditions are met */
        while (((GPIOC->IDR & STM32_DataStruct.STM32_CommandStruct.LGA_TriggerMask) == tmp) & (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut != 0))
        {
        }
        /* Wait until conditions are met */
        while (((GPIOC->IDR & STM32_DataStruct.STM32_CommandStruct.LGA_TriggerMask) != tmp) & (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut != 0))
        {
        }
        break;
      }
      else
      {
        /* Wait until conditions are met */
        while (((GPIOC->IDR & STM32_DataStruct.STM32_CommandStruct.LGA_TriggerMask) != tmp) & (STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut != 0))
        {
        }
      }
      break;
    default:
      break;
  }
}

/*******************************************************************************
* Function Name  : FAST_LGA_Read
* Description    : This function reads 128 bytes from PC.00 to PC.07 to ram.
*                  The rate is 9.333MHz.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void FAST_LGA_Read(void)
{
  u8 *Adr;
  Adr = (u8 *)&STM32_DataStruct.STM32_Data;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 16
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 32
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 48
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 64
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 80
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 96
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 112
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  *Adr = (u8)GPIOC->IDR;
  Adr++;
  // 128
}

/*******************************************************************************
* Function Name  : TIM2_IRQHandler
* Description    : This function handles TIM2 global interrupt request.
*                  It increments the TIM2H 16 bit variable on each rollover
*                  of the counter.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM2_IRQHandler(void)
{
  /* Clear TIM2 Update interrupt pending bit */
  asm("mov    r1,#0x40000000");
  asm("strh   r1,[r1,#0x10]");
  /* Increment STM32_DataStruct.STM32_FRQDataStructCHA.TIMxH */
  asm("mov    r1,#0x20000000");
  asm("ldrh   r2,[r1,0xe]");
  asm("add    r2,r2,0x1");
  asm("strh   r2,[r1,0xe]");
}

/*******************************************************************************
* Function Name  : TIM3_IRQHandler
* Description    : This function handles TIM3 global interrupt request.
*                  It calculates the frequency every 1000ms.
*                  Since it calculate the difference between this reading
*                  and the previous reading there is no need to take into
*                  account interrupt overhead.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM3_IRQHandler(void)
{
  /* Clear TIM3 Update interrupt pending bit */
  asm("mov    r0,#0x0");
  asm("movw   r1,#0x0400");
  asm("movt   r1,#0x4000");
  asm("strh   r0,[r1,#0x10]");
  /* Decrement STM32_DataStruct.STM32_CommandStruct.TIM3_TimeOut */
  asm("mov    r1,#0x20000000");
  asm("ldrb   r0,[r1,0x2f]");
  asm("cmp    r0,0x0");
  asm("itt    ne");
  asm("subne  r0,r0,0x1");
  asm("strbne r0,[r1,0x2f]");
  /* Calculate frequency TIM2 */
  asm("mov    r0,#0x40000000");
  asm("mov    r1,#0x20000000");
  asm("ldrh   r2,[r1,0xe]");        // STM32_DataStruct.STM32_FRQDataStructCHA.TIMxH
  asm("ldrh   r3,[r0,#0x24]");      // TIM2->CNT
  asm("orr    r2,r3,r2,lsl #16");   // (STM32_DataStruct.STM32_FRQDataStructCHA.TIMxH << 16) | TIM2->CNT
  asm("ldr    r3,[r1,0x4]");        // STM32_DataStruct.STM32_FRQDataStructCHA.PreviousCount
  asm("str    r2,[r1,0x4]");        // STM32_DataStruct.STM32_FRQDataStructCHA.PreviousCount
  asm("sub    r2,r2,r3");
  asm("str    r2,[r1,0x0]");        // STM32_DataStruct.STM32_FRQDataStructCHA.Frequency
  /* Calculate frequency TIM4 */
  asm("movw   r0,#0x0800");
  asm("movt   r0,#0x4000");
  asm("ldrh   r2,[r1,0x1e]");       // STM32_DataStruct.STM32_FRQDataStructCHB.TIMxH
  asm("ldrh   r3,[r0,#0x24]");      // TIM4->CNT
  asm("orr    r2,r3,r2,lsl #16");   // (STM32_DataStruct.STM32_FRQDataStructCHB.TIMxH << 16) | TIM4->CNT
  asm("ldr    r3,[r1,0x14]");       // STM32_DataStruct.STM32_FRQDataStructCHB.PreviousCount
  asm("str    r2,[r1,0x14]");       // STM32_DataStruct.STM32_FRQDataStructCHB.PreviousCount
  asm("sub    r2,r2,r3");
  asm("str    r2,[r1,0x10]");       // STM32_DataStruct.STM32_FRQDataStructCHB.Frequency
}

/*******************************************************************************
* Function Name  : TIM4_IRQHandler
* Description    : This function handles TIM4 global interrupt request.
*                  It increments the TIM4H 16 bit variable on each rollover
*                  of the counter.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM4_IRQHandler(void)
{
  /* Clear TIM4 Update interrupt pending bit */
  asm("mov    r2,#0x0");
  asm("movw   r1,#0x0800");
  asm("movt   r1,#0x4000");
  asm("strh   r2,[r1,#0x10]");
  /* Increment STM32_DataStruct.STM32_FRQDataStructCHB.TIMxH */
  asm("mov    r1,#0x20000000");
  asm("ldrh   r2,[r1,0x1e]");
  asm("add    r2,r2,0x1");
  asm("strh   r2,[r1,0x1e]");
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
* Function Name  : ADC_Configuration
* Description    : This function prepares ADC1
*                  for DMA transfer on channel 8 and / or channel 9.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void ADC_Configuration(void)
{
  ADC_InitTypeDef ADC_InitStructure;
  ADC_AutoInjectedConvCmd(ADC1, DISABLE);
  /* Setup ADC Clock divisor */
  switch (STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateH)
  {
    case (0):
      /* ADCCLK = PCLK2/2 */
      RCC_ADCCLKConfig(RCC_PCLK2_Div2);
      break;
    case (1):
      /* ADCCLK = PCLK2/4 */
      RCC_ADCCLKConfig(RCC_PCLK2_Div4);
      break;
    case (2):
      /* ADCCLK = PCLK2/6 */
      RCC_ADCCLKConfig(RCC_PCLK2_Div6);
      break;
    case (3):
      /* ADCCLK = PCLK2/8 */
      RCC_ADCCLKConfig(RCC_PCLK2_Div8);
      break;
  }
  ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;
  ADC_InitStructure.ADC_ScanConvMode = ENABLE;
  ADC_InitStructure.ADC_ContinuousConvMode = ENABLE;
  ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;
  ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Left;
  switch (STM32_DataStruct.STM32_CommandStruct.STM32_Mode)
  {
    case STM32_ModeScopeCHA:
      /* ADC1 single channel (CHA) configuration -----------------------------*/
      ADC_InitStructure.ADC_NbrOfChannel = 1;
      break;
    case STM32_ModeScopeCHB:
      /* ADC1 single channel (CHB) configuration -----------------------------*/
      ADC_InitStructure.ADC_NbrOfChannel = 1;
      break;
    case STM32_ModeScopeCHACHB:
      /* ADC1 dual channel configuration -------------------------------------*/
      ADC_InitStructure.ADC_NbrOfChannel = 2;
      break;
  }
  ADC_Init(ADC1, &ADC_InitStructure);
}

/*******************************************************************************
* Function Name  : DMA_ADC_Configuration
* Description    : Configures the DMA1 channel 1 to transfer ADC data to memory.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMA_ADC_Configuration(void)
{
  DMA_InitTypeDef DMA_InitStructure;
  DMA_DeInit(DMA1_Channel1);
  DMA_DeInit(DMA1_Channel5);
  DMA_InitStructure.DMA_PeripheralBaseAddr = ADC1_DR_Address+1;
  DMA_InitStructure.DMA_MemoryBaseAddr = (u32)&STM32_DataStruct.STM32_Data;
  DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;
  DMA_InitStructure.DMA_BufferSize = (u32)(STM32_DataStruct.STM32_CommandStruct.STM32_DataBlocks * STM32_BlockSize * 2) - 2;
  DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
  DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
  DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
  DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
  DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
  DMA_InitStructure.DMA_Priority = DMA_Priority_High;
  DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;
  DMA_Init(DMA1_Channel1, &DMA_InitStructure);
  /* Clear all interrupt pending bits */
  DMA1->IFCR =0x0FFFFFFF;
}

/*******************************************************************************
* Function Name  : DMA_LGA_Configuration
* Description    : Configures the DMA1 channel 5 to transfer PC.00 to PC.07
*                  data to memory on each rollover of TIM15.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void DMA_LGA_Configuration(void)
{
  DMA_InitTypeDef DMA_InitStructure;
  DMA_DeInit(DMA1_Channel1);
  DMA_DeInit(DMA1_Channel5);
  DMA_InitStructure.DMA_PeripheralBaseAddr = PC_IDR_Address;
  DMA_InitStructure.DMA_MemoryBaseAddr = (u32)&STM32_DataStruct.STM32_Data;
  DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;
  DMA_InitStructure.DMA_BufferSize = (u32)(STM32_DataStruct.STM32_CommandStruct.STM32_DataBlocks * STM32_BlockSize * 2) - 2;
  DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
  DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
  DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
  DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
  DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
  DMA_InitStructure.DMA_Priority = DMA_Priority_High;
  DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;
  DMA_Init(DMA1_Channel5, &DMA_InitStructure);
  /* Clear all interrupt pending bits */
  DMA1->IFCR =0x0FFFFFFF;
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
  /* Enable DMA1 clock */
  RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
  /* Enable TIM1, ADC1, GPIOA, GPIOB and GPIOC clock */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1 | RCC_APB2Periph_TIM15 | RCC_APB2Periph_TIM16 | RCC_APB2Periph_TIM17 | RCC_APB2Periph_ADC1 | RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB | RCC_APB2Periph_GPIOC, ENABLE);
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
  /* Configure ADC Channel9 (PB.01) and ADC Channel8 (PB.00) as analog input */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1 | GPIO_Pin_0;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOB, &GPIO_InitStructure);
  /* Configure DAC Channel1 (PA.04), DAC Channel2 (PA.05), ADC Channel2 (PA.02) and ADC Channel3 (PA.03) as analog input */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7 | GPIO_Pin_6 | GPIO_Pin_5 | GPIO_Pin_4 | GPIO_Pin_3 | GPIO_Pin_2;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* Configure PC.09 (LED3) and PC.08 (LED4) as output */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_8;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOC, &GPIO_InitStructure);
  /* TIM2 channel 2 pin (PA.01) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* TIM4 channel 2 pin (PB.07) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOB, &GPIO_InitStructure);
  /* TIM16 Channel 1 pin (PB.08, TIM17 Channel 1 pin (PB.09) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_8;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOB, &GPIO_InitStructure);
  /* TIM1 channel 1 pin (PA.08), channel 2 pin (PA.09), channel 3 pin (PA.10) and channel 4 pin (PA.11) configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_11 | GPIO_Pin_10 | GPIO_Pin_9 | GPIO_Pin_8;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* LGA PC.07 to PC.00 configuration */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7 | GPIO_Pin_6 | GPIO_Pin_5 | GPIO_Pin_4 | GPIO_Pin_3 | GPIO_Pin_2 | GPIO_Pin_1 | GPIO_Pin_0;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOC, &GPIO_InitStructure);
  /* Scope CHA / CHB amplification selector (Open Drain Output) */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_15 | GPIO_Pin_14 | GPIO_Pin_13 | GPIO_Pin_12 | GPIO_Pin_11 | GPIO_Pin_10;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_OD;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOB, &GPIO_InitStructure);
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
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  /* Enable the TIM3 global Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM3_IRQChannel;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  /* Enable the TIM4 global Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM4_IRQChannel;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}

/*******************************************************************************
* Function Name  : TIM1_Configuration
* Description    : Configures TIM1 to generate PWM output.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM1_Configuration(void)
{
  /* -----------------------------------------------------------------------
    TIM1 Configuration: generate 4 PWM signals with 4 different duty cycles:
    TIM1CLK = 28 MHz, Prescaler = 0x0, TIM1 counter clock = 28 MHz
    TIM1 ARR Register = 255 => TIM1 Frequency = TIM1 counter clock/(ARR + 1)
    TIM1 Frequency = 109.375 KHz.
    TIM1 Channel1 duty cycle = (TIM1_CCR1 / TIM1_ARR)* 100
    TIM1 Channel2 duty cycle = (TIM1_CCR2 / TIM1_ARR)* 100
    TIM1 Channel3 duty cycle = (TIM1_CCR3 / TIM1_ARR)* 100
    TIM1 Channel4 duty cycle = (TIM1_CCR4 / TIM1_ARR)* 100
  ----------------------------------------------------------------------- */

  TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
  TIM_OCInitTypeDef  TIM_OCInitStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 255;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM1, &TIM_TimeBaseStructure);

  TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;
  TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
  TIM_OCInitStructure.TIM_OutputNState = TIM_OutputState_Disable;
  TIM_OCInitStructure.TIM_Pulse = (u16)0x7F;
  TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
  TIM_OCInitStructure.TIM_OCNPolarity = TIM_OCPolarity_Low;
  TIM_OCInitStructure.TIM_OCIdleState = TIM_OCIdleState_Reset;
  TIM_OCInitStructure.TIM_OCNIdleState = TIM_OCIdleState_Reset;
  /* PWM1 Mode configuration: Channel1 */
  TIM_OC1Init(TIM1, &TIM_OCInitStructure);
  TIM_OC1PreloadConfig(TIM1, TIM_OCPreload_Enable);
  /* PWM1 Mode configuration: Channel2 */
  TIM_OC2Init(TIM1, &TIM_OCInitStructure);
  TIM_OC2PreloadConfig(TIM1, TIM_OCPreload_Enable);
  /* PWM1 Mode configuration: Channel3 */
  TIM_OC3Init(TIM1, &TIM_OCInitStructure);
  TIM_OC3PreloadConfig(TIM1, TIM_OCPreload_Enable);
  /* PWM1 Mode configuration: Channel4 */
  TIM_OC4Init(TIM1, &TIM_OCInitStructure);
  TIM_OC4PreloadConfig(TIM1, TIM_OCPreload_Enable);
  /* TIM1 enable counter */
  TIM_Cmd(TIM1, ENABLE);
  /* TIM1 Main Output Enable */
  TIM_CtrlPWMOutputs(TIM1, ENABLE);
}

/*******************************************************************************
* Function Name  : TIM2_Configuration
* Description    : Configures TIM2 to count up on rising edges on CH2 PA.01
*                  An interrupt is generated on each rollover.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM2_Configuration(void)
{
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 0xffff;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM2, &TIM_TimeBaseStructure);
  TIM2->CCMR1 = 0x0100;     //CC2S=01
  TIM2->SMCR = 0x0067;      //TS=110, SMS=111
}

/*******************************************************************************
* Function Name  : TIM3_Configuration
* Description    : Configures TIM3 to count up and generate interrupt every 1000ms.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM3_Configuration(void)
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
  TIM_TimeBaseInit(TIM3, &TIM_TimeBaseStructure);
  TIM_InternalClockConfig(TIM3);
}

/*******************************************************************************
* Function Name  : TIM4_Configuration
* Description    : Configures TIM4 to count up on rising edges on CH2 PB.07
*                  An interrupt is generated on each rollover.
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
  TIM4->CCMR1 = 0x0001;     //CC2S=01
  TIM4->SMCR = 0x0067;      //TS=110, SMS=111
}

/*******************************************************************************
* Function Name  : TIM6_Configuration
* Description    : Configures TIM6 to count up.
*                  A TRG0 signal is generated on each rollover.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM6_Configuration(void)
{
  /* TIM6 TRGO selection */
  TIM_SelectOutputTrigger(TIM6, TIM_TRGOSource_Update);
  /* TIM6 enable counter */
  TIM_Cmd(TIM6, ENABLE);
}

/*******************************************************************************
* Function Name  : TIM7_Configuration
* Description    : Configures TIM7 to count up.
*                  A TRG0 signal is generated on each rollover.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM7_Configuration(void)
{
  /* TIM6 TRGO selection */
  TIM_SelectOutputTrigger(TIM7, TIM_TRGOSource_Update);
  /* TIM7 enable counter */
  TIM_Cmd(TIM7, ENABLE);
}

/*******************************************************************************
* Function Name  : TIM15_Configuration
* Description    : Configures TIM115 to count up.
*                  A DMA request is generated on each rollover.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM15_Configuration()
{
  TIM_DeInit(TIM15);
  TIM_TimeBaseInitTypeDef TIM_TimeBaseStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = (STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateH << 8) + STM32_DataStruct.STM32_CommandStruct.STM32_SampleRateL;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM15, &TIM_TimeBaseStructure);
  TIM_DMACmd(TIM15,TIM_DMA_Update,ENABLE);
}

/*******************************************************************************
* Function Name  : TIM16_Configuration
* Description    : Configures TIM16 to generate PWM output.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM16_Configuration(void)
{
  TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
  TIM_OCInitTypeDef  TIM_OCInitStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 255;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM16, &TIM_TimeBaseStructure);
  /* PWM1 Mode configuration: Channel1 */
  TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;
  TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
  TIM_OCInitStructure.TIM_Pulse = (u16)0x0000;
  TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
  TIM_OC1Init(TIM16, &TIM_OCInitStructure);
  TIM_OC1PreloadConfig(TIM16, TIM_OCPreload_Enable);
  TIM16->CCR1 = (u16)0x7F;
  /* TIM16 Main Output Enable */
  TIM_CtrlPWMOutputs(TIM16, ENABLE);
}

/*******************************************************************************
* Function Name  : TIM17_Configuration
* Description    : Configures TIM17 to generate PWM output.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void TIM17_Configuration(void)
{
  TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
  TIM_OCInitTypeDef  TIM_OCInitStructure;
  /* Time base configuration */
  TIM_TimeBaseStructure.TIM_Period = 255;
  TIM_TimeBaseStructure.TIM_Prescaler = 0;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseInit(TIM17, &TIM_TimeBaseStructure);
  /* PWM1 Mode configuration: Channel1 */
  TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;
  TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
  TIM_OCInitStructure.TIM_Pulse = (u16)0x0000;
  TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
  TIM_OC1Init(TIM17, &TIM_OCInitStructure);
  TIM_OC1PreloadConfig(TIM17, TIM_OCPreload_Enable);
  TIM17->CCR1 = (u16)0x7F;
  /* TIM17 Main Output Enable */
  TIM_CtrlPWMOutputs(TIM17, ENABLE);
}

/*****END OF FILE****/
