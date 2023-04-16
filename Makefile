all: build/main.o build/system.o build/startup_stm32f411retx.o
	@echo ""
	@echo "build the elf file with the object files"
	arm-none-eabi-gcc -mcpu=cortex-m4 -mlittle-endian -mthumb -DSTM32F411xE -Tlinker/STM32F411RETX_FLASH.ld -Wl,--gc-sections build/system.o build/main.o build/startup_stm32f411retx.o -o main.elf
	arm-none-eabi-objcopy -Oihex main.elf main.hex

build/main.o: src/main.c
	@echo ""
	@echo "build main.o"
	arm-none-eabi-gcc -Wall -mcpu=cortex-m4 -mlittle-endian -mthumb -Iinc/Drivers/CMSIS/Device/ST/STM32F4xx/Include -Iinc/Drivers/CMSIS/Core/Include -DSTM32F411xE -Os -c src/main.c -o build/main.o
	
build/system.o: src/system.c
	@echo ""
	@echo "build system.o for SystemInit and SystemInitError"
	arm-none-eabi-gcc -Wall -mcpu=cortex-m4 -mlittle-endian -mthumb -Iinc/Drivers/CMSIS/Device/ST/STM32F4xx/Include -Iinc/Drivers/CMSIS/Core/Include -DSTM32F411xE -Os -c src/system.c -o build/system.o

# assemble the startup code
build/startup_stm32f411retx.o: startup/startup_stm32f411retx.s
	@echo ""
	@echo "run assembler for startup_stm32f411retx.s"
	arm-none-eabi-as startup/startup_stm32f411retx.s -o build/startup_stm32f411retx.o

clean:
	rm build/*
	rm *.elf
	rm *.hex