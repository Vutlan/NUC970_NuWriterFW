OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
/* Entry Point */
ENTRY(Reset_Go)

/* Specify the memory areas */
/*
MEMORY
{  
  RAM (xrw)       : ORIGIN = 0x03F00040, LENGTH = 6M
}
*/
SECTIONS
{
	. = 0x03F00040;
	. = ALIGN(4);
		
	.text	:
	{
	  KEEP(*(.text.wb_init))   /* Startup code */
	  *(.text.*)
	  
	  . = ALIGN(4);
	  *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*)))
	  
	  . = ALIGN(4);
	  *(.data)
	  
	  . = ALIGN(4);
	  __rel_dyn_start = .;
		*(.rel*)
		__rel_dyn_end = .;
		
	    . = ALIGN(4);	
		__dynsym_start = .;
		*(.dynsym)
	}

	.bss : {
		. = ALIGN(4);
/*		__bss_start = .;  */
		__bss_start__ = .;
		*(.bss*)
		. = ALIGN(4);
/*		__bss_end = .;  */
		__bss_end__ = .;
	} 
	
	.heap : {
		. = ALIGN(4);
		__heap_start__ = .;
		end = __heap_start__;
		_end = end;
		__end = end;
		KEEP(*(.heap))
		__heap_end__ = .;
		__HeapLimit = __heap_end__;
	}
	

	/DISCARD/ : { *(.dynstr*) }
	/DISCARD/ : { *(.dynsym*) }
	/DISCARD/ : { *(.dynamic*) }
	/DISCARD/ : { *(.hash*) }
	/DISCARD/ : { *(.plt*) }
	/DISCARD/ : { *(.interp*) }
	/DISCARD/ : { *(.gnu*) }
}
  
  