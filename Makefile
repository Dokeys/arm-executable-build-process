# Makefile to demonstrate the Toolchain
# Maybe this helps: http://regalis.com.pl/en/arm-cortex-stm32-gnulinux/#what_do_we_need%3F

# build firmware with own written linker and startup files
simple: firmware_simple.elf 
	@echo "simple target"

# build firmware with linker and startup files copyed from CubeIDE
cube: firmware_cube.elf 
	@echo "cube target"

# link it to get the executable
# TODO don't work. cannot find libc.a: No such file or directory
firmware_simple.elf: build/main.o build/c_startup.o
	@echo "____"
	@echo "link everything to get the executable"
	arm-none-eabi-gcc -nostdlib -o firmware_simple.elf -T linker/controller.ld build/main.o build/c_startup.o -lgcc 

firmware_cube.elf: build/main.o build/startup_stm32f411retx.o
	@echo "____"
	@echo "link everything to get the executable"
	arm-none-eabi-gcc -nostdlib -o firmware_cube.elf -T STM32F411RETX_FLASH.ld main.o startup_stm32f411retx.o -lgcc 
	# from example: arm-none-eabi-gcc -g3 -nostdlib -o firmware.elf -T linker/firmware.ld build/main.o build/c_startup.o -L. -lfilter -lgcc

# assemble the startup code
build/c_startup.o: startup/c_startup.s
	@echo "____"
	@echo "run assembler for the simpele c_startup.s file"
	arm-none-eabi-as startup/c_startup.s -o build/c_startup.o

# assemble the startup code
build/startup_stm32f411retx.o: startup/startup_stm32f411retx.s
	@echo "____"
	@echo "run assembler for startup_stm32f411retx.s"
	arm-none-eabi-as startup/startup_stm32f411retx.s -o build/startup_stm32f411retx.o

# The assembler generates a linkable binary file also called object file.
build/main.o: build/main.s
	@echo "____"
	@echo "run assembler for main.s"
	arm-none-eabi-as build/main.s -o build/main.o
	@echo "generated file:"
	file build/main.o

# The compiler builds the assembler file. He is responsible for "translation", memory reservation
# and code optimisation.
build/main.s: build/main.i
	@echo "____"
	@echo "run compiler for main.i:"
	arm-none-eabi-gcc -S -mcpu=cortex-m4 -mfloat-abi=hard build/main.i -o build/main.s
	@echo "generated file:"
	file build/main.s

# The pre-processor can be seen as an search and replace tool. Copies all the defines, macros and
# and puts the content of the include files to the specified place.
build/main.i: src/main.c
	@echo "____"
	@echo "run pre-processor for main.c:"
	arm-none-eabi-gcc -E src/main.c -o build/main.i
	@echo "generated file:"
	file build/main.i

clean:
	rm build/* 
