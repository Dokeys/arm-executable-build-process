/*
 *
 * https://controllerstech.com/stm32-clock-setup-using-registers/
 */
#include "stm32f411xe.h"

void SystemInitError(uint8_t error_source);

// TODO configure for stm32f411
/**
 * @brief Configure the clocks for the NUCLEO-F411RE board
 *
 * Configure HCLK to 100 MHz with external oszillator.
 * - 8MHz oszillator is connected to HSE
 *
 */
void SystemInit(void)
{
	/* Enable HSE */
	RCC->CR |= RCC_CR_HSEON;
	/* Wait until HSE is stable */
	while (!(RCC->CR & RCC_CR_HSERDY))
		;

	/* Enable power interface clock */
	RCC->APB1ENR |= RCC_APB1ENR_PWREN;
	/* Set regulator voltage scaling output section to Scale 1 mode <= 100 MHz */
	PWR->CR |= 3 << PWR_CR_VOS_Pos;

	/* Set flash access control register */
	FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS;

	/* Set AHB prescaler to /1 */
	RCC->CFGR = RCC_CFGR_HPRE_DIV1;
	/* Set APB1 prescaler to /2 */
	RCC->CFGR |= RCC_CFGR_PPRE1_DIV2;
	/* Set APB2 prescaler to /1 */
	RCC->CFGR |= RCC_CFGR_PPRE2_DIV1;

	/* Set in RCC PLL configuration register PLL_M = /4, PLL_N = x100, PLL_P = /2 and PLLSRC to HSE*/
	RCC->PLLCFGR = (4 << RCC_PLLCFGR_PLLM_Pos) | (100 << RCC_PLLCFGR_PLLN_Pos) | (2 << RCC_PLLCFGR_PLLP_Pos) | RCC_PLLCFGR_PLLSRC_HSE;

	/* Set PLL ON in RCC clock control register */
	RCC->CR |= RCC_CR_PLLON;
	while (!(RCC->CR & RCC_CR_PLLRDY))
		;

	/* Set the system clock switch (mux) to PLL in the RCC clock configuration register */
	RCC->CFGR |= RCC_CFGR_SW_PLL;
	while (!(RCC->CFGR & RCC_CFGR_SWS_PLL))
		;
}

void SystemInitError(uint8_t error_source)
{
	while (1)
		;
}
