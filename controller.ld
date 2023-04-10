MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 512K
  SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

ENTRY(Reset_Handler)

SECTIONS
{
  .text :
  {
    KEEP(*(.isr_vector))
    *(.text*)
    *(.rodata*)
  } > FLASH

  .data :
  {
    *(.data*)
  } > SRAM AT > FLASH

  .bss :
  {
    *(.bss*)
  } > SRAM
}

INCLUDE c_startup.o
INPUT ( main.o ) 

OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
