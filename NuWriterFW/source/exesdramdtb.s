    ///***************************************************************************
    // *                                                                         *
    // * Copyright (c) 2017 Nuvoton Technolog. All rights reserved.              *
    // *                                                                         *
    // ***************************************************************************/
    //
    .arm
//    AREA DTB_INIT, CODE, READONLY
	.section ".text.dtb_init"
    
//    EXPORT  fw_dtbfunc
	.global	fw_dtbfunc

fw_dtbfunc:

    BX r3;
//    END
    
