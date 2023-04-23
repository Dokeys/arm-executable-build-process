/*
 * main.c
 *
 * Creaded on: 23.04.2023
 * Autor: Dominik Knoll
 *
 * Description:
 * This is the main file for the arm-executable-build-process.
 * This file let the user led of the NUCLEO-F411RE on Port A5 flash,
 * without the use of the STM32 HAL.
 */

#include "stm32f411xe.h"

/** @brief init the user led
 * User led on the NUCLEO-F411 board is PortA5.
 */
static void init_user_led(void)
{
	/* enable the GPIOA peripheral clock */
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;

	/* configure PA5 as output */
	GPIOA->MODER |= GPIO_MODER_MODE5_0;

	/* setup GPIO port output speed register to speed medium */
	GPIOA->OSPEEDR |= GPIO_OSPEEDR_OSPEED5_0;

	/* set teh initial output value of PA5 to high */
	GPIOA->ODR |= GPIO_ODR_OD5;
}

static void set_user_led(void)
{
	/* set output pin high on GPIO port bit set/reset register */
	GPIOA->BSRR |= GPIO_BSRR_BS5;
}

static void reset_user_led(void)
{
	/* set output pin high on GPIO port bit set/reset register */
	GPIOA->BSRR |= GPIO_BRR_BR5;
}

static void delay(uint32_t timeMs)
{
	for (uint32_t i = 0; i <= timeMs; i++)
	{
		for (uint32_t j = 0; j <= 10000; j++) /* this for loops takes 1ms */
			asm("NOP");						  /* with the 100 MHz one NOP cycle shout take 10 nano secounds*/
	}
}

int main(void)
{
	init_user_led();
	while (1)
	{
		set_user_led();
		delay(1000);
		reset_user_led();
		delay(1000);
	}
}
