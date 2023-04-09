# Makefile to demonstrate the Toolchain

# link it to get the executable
# TODO don't work. cannot find libc.a: No such file or directory
firmware.elf: main.o startup_stm32f411retx.o
	arm-none-eabi-gcc -nostdlib -o firmware.elf -T STM32F411RETX_FLASH.ld main.o startup_stm32f411retx.o -lgcc 
	# from example: arm-none-eabi-gcc -g3 -nostdlib -o firmware.elf -T firmware.ld main.o c_startup.o -L. -lfilter -lgcc

# assemble the startup code
startup_stm32f411retx.o: startup_stm32f411retx.s
	arm-none-eabi-as startup_stm32f411retx.s -o startup_stm32f411retx.o

# The assembler generates a linkable binary file also called object file.
main.o: main.s
	echo "run assembler"
	arm-none-eabi-as main.s -o main.o
	file main.o

# The compiler builds the assembler file. He is responsible for "translation", memory reservation
# and code optimisation.
main.s: main.i
	echo "run compiler"
	arm-none-eabi-gcc -S -mcpu=cortex-m4 -mfloat-abi=hard main.i -o main.s
	file main.s

# The pre-processor can be seen as an search and replace tool. Copies all the defines, macros and
# and puts the content of the include files to the specified place.
main.i: main.c
	echo "run pre-processor"
	arm-none-eabi-gcc -E main.c -o main.i
	file main.i

clean:
	rm *.i main.s *.o
