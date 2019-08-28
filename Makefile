CROSS_COMPILE ?=/opt/gcc-arm-none-eabi-6-2017-q1-update/bin/arm-none-eabi-

# Set CROSS_COMPILE to match your EABI toolchain, e.g.:
# make CROSS_COMPILE=/path/to/arm-2011.03/bin/arm-none-eabi-
CC      = $(CROSS_COMPILE)gcc
AS      = $(CROSS_COMPILE)as
LD      = $(CROSS_COMPILE)gcc
CP      = ${CROSS_COMPILE}objcopy
OD      = ${CROSS_COMPILE}objdump
SIZE    = ${CROSS_COMPILE}size

PROJECT = NuWriterFW_64MB_gcc

XUSB_PATH = ./NuWriterFW/

FW_PATH = ./NuWriterFW/source/
SYSLIB_PATH = ./SYSLIB/


# We need to add stubs or implementations for certain C library functions:
#CSTUBS = ../src/newlib_stubs.c

# We need to specify a linker script for the linker
LDSCRIPT_REL = ./$(FW_PATH)link64.ld
LDSCRIPT_DEV = ./$(FW_PATH)link64.ld

# NuWriter firmware source files
FW_CFILES = $(FW_PATH)main.c $(FW_PATH)parse.c \
$(FW_PATH)sm.c \
$(FW_PATH)sdglue.c \
$(FW_PATH)filesystem.c \
$(FW_PATH)flash.c \
$(FW_PATH)sd.c \
$(FW_PATH)usbd.c \
$(FW_PATH)spiflash.c


#  Assembly source files
FW_ASMFILES = $(FW_PATH)wb_init_64.s $(FW_PATH)exesdramdtb.s

# System library source files
SYSLIB_SRC = $(SYSLIB_PATH)Src/wb_aic.c $(SYSLIB_PATH)Src/wb_config.c \
$(SYSLIB_PATH)Src/wb_mmu.c $(SYSLIB_PATH)Src/wb_timer.c \
$(SYSLIB_PATH)Src/wb_cache.c $(SYSLIB_PATH)Src/wb_ebi.c \
$(SYSLIB_PATH)Src/wb_uart.c \
$(wildcard $(SYSLIB_PATH)Src/*.s) \

INC = -I$(SYSLIB_PATH)Lib -I$(FW_PATH)

#  C source files
SYSLIB_CFILES = $(filter %.c, $(SYSLIB_SRC))
#  Assembly source files
SYSLIB_ASMFILES = $(filter %.s, $(SYSLIB_SRC))

# Object files
SYSLIB_COBJ = $(SYSLIB_CFILES:.c=.o)
SYSLIB_SOBJ = $(SYSLIB_ASMFILES:.s=.o)
SYSLIB_OBJ  = $(SYSLIB_COBJ) $(SYSLIB_SOBJ)

FW_COBJ = $(FW_CFILES:.c=.o)
FW_SOBJ = $(FW_ASMFILES:.s=.o)
FW_OBJ = $(FW_COBJ) $(FW_SOBJ)

ALL_OBJ = $(SYSLIB_OBJ) $(FW_OBJ) 


# Compile options 
COMMONFLAGS = -mlittle-endian
CFLAGS  = $(COMMONFLAGS) -marm -mtune=arm926ej-s -specs=nano.specs -specs=nosys.specs -Wall -std=c99 -fomit-frame-pointer -funroll-loops -ffunction-sections -fdata-sections -nostartfiles
ASFLAGS = $(COMMONFLAGS) -mcpu=arm926ej-s
#-march=armv5te
LDFLAGS = $(COMMONFLAGS) -specs=nano.specs -specs=nosys.specs -Wl,-Map,$(PROJECT).map,--cref
#--gc-sections,

# Debug or release build ?
ifeq ($(BUILD),devel)
CFLAGS += -O2 -ggdb -DDEBUG -DMSG_DEBUG_EN
LDFLAGS += -O2 -ggdb -T$(LDSCRIPT_DEV) -Wl,--gc-sections,-Map,$(PROJECT).map,--cref
else
CFLAGS += -O0 -DDEBUG -DMSG_DEBUG_EN
LDFLAGS += -O0 -T$(LDSCRIPT_REL) -Wl,--gc-sections,-Map,$(PROJECT).map,--cref
endif 

CFLAGS += -DTURBOWRITER64
#CFLAGS += -DTURBOWRITER32
#CFLAGS += -DTURBOWRITER16


#all: $(SRC) $(PROJECT).elf $(PROJECT).bin
all: $(PROJECT).bin
	mv $(PROJECT).bin $(XUSB_PATH)
	cd $(XUSB_PATH) && ./header_64MB.sh
	@echo Done	

$(PROJECT).bin: $(PROJECT).elf
	$(CP) -O binary $< $@
 
$(PROJECT).elf: $(ALL_OBJ)
	$(LD) $(LDFLAGS) $(ALL_OBJ) -o $@
#	$(OD) -d $@ >./disasm.txt

$(FW_COBJ): %.o: %.c
	@$(CC) -c $(INC) $(CFLAGS) $< -o $@

$(FW_SOBJ): %.o: %.s
	$(AS) -c $(ASFLAGS) $< -o $@

$(SYSLIB_COBJ): %.o: %.c
	$(CC) -c $(INC) $(CFLAGS) $< -o $@

$(SYSLIB_SOBJ): %.o: %.s
	$(AS) -c $(ASFLAGS) $< -o $@
	
clean:
	rm -f $(ALL_OBJ)
	rm -f *.map *.elf *.bin	 
	rm -f $(XUSB_PATH)*.bin 
	
#Help option
help:
	@echo "  make [target] [OPTIONS]"
	@echo
	@echo " Targets:"
	@echo "     all             Builds the app.  This is the default target."
	@echo "     clean           Clean all the objects and apps."
	@echo "     help            Prints this message."
	@echo " Options:"
	@echo "     BUILD=rel       Build a release build (default)"
	@echo "     BUILD=devel     Build a debug build"
