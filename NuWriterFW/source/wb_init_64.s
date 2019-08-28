
	.arm
	//AREA WB_INIT, CODE, READONLY
	.section ".text.wb_init"

//--------------------------------------------
// Mode bits and interrupt flag (I&F) defines
//--------------------------------------------
.set USR_MODE, 0x10
.set FIQ_MODE, 0x11
.set IRQ_MODE, 0x12
.set SVC_MODE, 0x13
.set ABT_MODE, 0x17
.set UDF_MODE, 0x1B
.set SYS_MODE, 0x1F

.set I_BIT,	0x80
.set F_BIT,	0x40

//----------------------------
// System / User Stack Memory
//----------------------------
.set RAM_Limit, 0x03FF0000         	// For unexpanded hardware board

.set UND_Stack,	RAM_Limit
.set Abort_Stack, RAM_Limit+1024
.set IRQ_Stack, RAM_Limit+2048      // followed by IRQ stack
.set FIQ_Stack, RAM_Limit+3072      // followed by IRQ stack
.set SVC_Stack, RAM_Limit+4096      // SVC stack at top of memory
.set USR_Stack,	RAM_Limit+5120

//	EXPORT  Reset_Go
.global Reset_Go


//        EXPORT	Vector_Table
.global Vector_Table
Vector_Table:
        B       Reset_Go    // Modified to be relative jumb for external boot
        LDR     PC, Undefined_Addr
        LDR     PC, SWI_Addr
        LDR     PC, Prefetch_Addr
        LDR     PC, Abort_Addr
        .word		0x0
        LDR     PC, IRQ_Addr
        LDR     PC, FIQ_Addr		
       
Reset_Addr:		.word     Reset_Go
Undefined_Addr:	.word     Undefined_Handler
SWI_Addr:		.word     SWI_Handler1
Prefetch_Addr:	.word     Prefetch_Handler
Abort_Addr:		.word     Abort_Handler
				.word		0
IRQ_Addr:      	.word     IRQ_Handler
FIQ_Addr:      	.word     FIQ_Handler


// ************************
// Exception Handlers
// ************************

// The following dummy handlers do not do anything useful in this example.
// They are set up here for completeness.

Undefined_Handler:
        B       Undefined_Handler
SWI_Handler1:
        B       SWI_Handler1     
Prefetch_Handler:
        B       Prefetch_Handler
Abort_Handler:
        B       Abort_Handler
IRQ_Handler:
		B		IRQ_Handler
FIQ_Handler:
        B       FIQ_Handler


//------------------------------------------------------
// clear memory area
//------------------------------------------------------
clmem_l:
    str	r2, [r0]
	add	r0, r0, #4
	cmp	r0, r1
	bcc	clmem_l
	bx  lr
	
Reset_Go:

//--------------------------------
// Initial Stack Pointer register
//--------------------------------
//INIT_STACK
 MSR	CPSR_c, #UDF_MODE | I_BIT | F_BIT
 LDR     SP, =UND_Stack

 MSR	CPSR_c, #ABT_MODE | I_BIT | F_BIT
 LDR     SP, =Abort_Stack

 MSR	CPSR_c, #IRQ_MODE | I_BIT | F_BIT
 LDR     SP, =IRQ_Stack

 MSR	CPSR_c, #FIQ_MODE | I_BIT | F_BIT
 LDR     SP, =FIQ_Stack

 MSR	CPSR_c, #SYS_MODE | I_BIT | F_BIT
 LDR     SP, =USR_Stack

 MSR	CPSR_c, #SVC_MODE | I_BIT | F_BIT
 LDR     SP, =SVC_Stack

//------------------------------------------------------
// Set the normal exception vector of CP15 control bit
//------------------------------------------------------
	MRC	p15, 0, r0 , c1, c0   	// r0 := cp15 register 1
	BIC r0, r0, #0x2000		// Clear bit13 in r1
	MCR p15, 0, r0 , c1, c0     // cp15 register 1 := r0
	
//------------------------------------------------------
// clear the bss section
//------------------------------------------------------
	ldr	r0, _bss_start
	ldr	r1, _bss_end
	mov	r2, #0x00000000
    bl	clmem_l


	//IMPORT	__main
	.extern	main
//-----------------------------
//	enter the C code
//-----------------------------
	B   main

.globl _bss_start
_bss_start:
	.word __bss_start__

.globl _bss_end
_bss_end:
	.word __bss_end__

	//END




