# Makefile to build a executable, debugging and demonstrate the toolchain for a STM32F411RE controller.
# Link to create a executable: http://regalis.com.pl/en/arm-cortex-stm32-gnulinux/#what_do_we_need%3F

# Variables
FIRMWARE_NAME := firmware
STARTUP_PATH := inc/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/
STARTUP_FILE_NAME := startup_stm32f411xe
INCLUDES := -Iinc/Drivers/CMSIS/Device/ST/STM32F4xx/Include -Iinc/Drivers/CMSIS/Core/Include 
BUILD_DIR := build/

# Build the executables
all: $(BUILD_DIR)main.o $(BUILD_DIR)system.o $(BUILD_DIR)$(STARTUP_FILE_NAME).o
	@echo "____"
	@echo "build the executable elf and hex file with the bevor generated object files:"
	# -Wl,--gc-sections – enable garbage collection of unused input sections
	# TODO why here cpu and that other stuff have to be speceified?
	arm-none-eabi-gcc -mcpu=cortex-m4 -mlittle-endian -mthumb -mfloat-abi=hard -DSTM32F411xE -Tlinker/STM32F411RETX_FLASH.ld -Wl,--gc-sections $(BUILD_DIR)system.o $(BUILD_DIR)main.o $(BUILD_DIR)$(STARTUP_FILE_NAME).o -o $(FIRMWARE_NAME).elf
	# generate a hex file form elf file
	arm-none-eabi-objcopy -Oihex $(FIRMWARE_NAME).elf $(FIRMWARE_NAME).hex

# Flash the program with openocd to the board. If necessary recompile it. 
flash: all 
	@echo "____"
	@echo "flash the program with openocd:"
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "program $(FIRMWARE_NAME).elf verify reset exit"

# The assembler generates a linkable binary file also called object file.
$(BUILD_DIR)main.o: $(BUILD_DIR)main.s
	@echo "____"
	@echo "run assembler for main.s:"
	arm-none-eabi-as $(BUILD_DIR)main.s -o $(BUILD_DIR)main.o
	@echo "generated file:"
	file $(BUILD_DIR)main.o

# The compiler builds the assembler file. He is responsible for "translation", memory reservation
# and code optimisation.
$(BUILD_DIR)main.s: $(BUILD_DIR)main.i
	@echo "____"
	@echo "run compiler for main.i:"
	# -mcpu=cortex-m4 – specify the target processor
	# -mlittle-endian – compile code for little endian target
	# -mthumb – generate core that executes in Thumb states
	# -c – do not run linker, just compile
	arm-none-eabi-gcc -S -Wall -mcpu=cortex-m4 -mlittle-endian -mthumb -mfloat-abi=hard -Os -c $(BUILD_DIR)main.i -o $(BUILD_DIR)main.s
	@echo "generated file:"
	file $(BUILD_DIR)main.s

# The pre-processor can be seen as an search and replace tool. Copies all the defines, macros and
# and puts the content of the include files to the specified place.
$(BUILD_DIR)main.i: src/main.c
	@echo "____"
	@echo "-> demonstarate the toolchain with main.c:"
	@echo "run pre-processor for main.c:"
	arm-none-eabi-gcc -E -Iinc/Drivers/CMSIS/Device/ST/STM32F4xx/Include -Iinc/Drivers/CMSIS/Core/Include -DSTM32F411xE src/main.c -o $(BUILD_DIR)main.i
	@echo "generated file:"
	file $(BUILD_DIR)main.i

# Build the linkable object file with just one command
$(BUILD_DIR)system.o: src/system.c
	@echo "____"
	@echo "build system.o for SystemInit and SystemInitError:"
	arm-none-eabi-gcc -Wall -mcpu=cortex-m4 -mlittle-endian -mthumb -mfloat-abi=hard -Iinc/Drivers/CMSIS/Device/ST/STM32F4xx/Include -Iinc/Drivers/CMSIS/Core/Include -DSTM32F411xE -Os -c src/system.c -o $(BUILD_DIR)system.o

# Assemble the startup code
$(BUILD_DIR)startup_stm32f411xe.o: $(STARTUP_PATH)$(STARTUP_FILE_NAME).s
	@echo "____"
	@echo "run assembler for startup_stm32f411retx.s:"
	arm-none-eabi-as $(STARTUP_PATH)$(STARTUP_FILE_NAME).s -o $(BUILD_DIR)$(STARTUP_FILE_NAME).o

clean:
	rm build/*
	rm *.elf
	rm *.hex