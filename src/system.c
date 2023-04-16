#include "stm32f411xe.h"

void SystemInitError(uint8_t error_source);

// TODO configure for stm32f411
void SystemInit(void)
{
	// Reset the RCC clock configuration to the default reset state
	RCC->CR |= RCC_CR_HSION;	// Enable HSI
	RCC->CFGR = 0x00000000;		// Reset CFGR
	RCC->CR &= ~(RCC_CR_PLLON); // Disable PLL
	while ((RCC->CR & RCC_CR_PLLRDY) != 0)
	{
	}										   // Wait for PLL to be unlocked
	RCC->CFGR &= ~(RCC_CFGR_SW);			   // Reset SW bits
	RCC->CR &= ~(RCC_CR_HSEON | RCC_CR_CSSON); // Disable HSE and CSS
	RCC->PLLCFGR = 0x24003010;				   // Reset PLLCFGR
	RCC->CR &= ~(RCC_CR_HSEBYP);			   // Disable HSE bypass
	FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_2WS;
	// Set Flash latency and enable prefetch buffer and cache
	RCC->CR |= RCC_CR_HSEON; // Enable HSE
	while ((RCC->CR & RCC_CR_HSERDY) == 0)
	{
	}															  // Wait for HSE to be ready
	RCC->PLLCFGR = (RCC_PLLCFGR_PLLSRC_HSE | RCC_PLLCFGR_PLLM_3); // | RCC_PLLCFGR_PLLN_96 | RCC_PLLCFGR_PLLP_7 | RCC_PLLCFGR_PLLQ_4);
	// Configure PLL
	RCC->CR |= RCC_CR_PLLON; // Enable PLL
	while ((RCC->CR & RCC_CR_PLLRDY) == 0)
	{
	}								// Wait for PLL to be ready
	RCC->CFGR |= (RCC_CFGR_SW_PLL); // Select PLL as system clock
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL)
	{
	} // Wait for PLL to be selected
}

void SystemInitError(uint8_t error_source)
{
	while (1)
		;
}
