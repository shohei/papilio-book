
# ==== TARGET BOARD =====================
BOARD = sim

# ==== GNU PATH =====================
GNUPATH    := /zpu/papilio-zap-ide/hardware/tools/zpu
GNUPREFIX  := $(GNUPATH)/bin/zpu-elf-
CRTOBJPATH := $(GNUPATH)/lib/gcc/zpu-elf/3.4.2/

AS := $(GNUPREFIX)gcc
CC := $(GNUPREFIX)gcc
LD := $(GNUPREFIX)gcc
AR := $(GNUPREFIX)ar
OC := $(GNUPREFIX)objcopy
OD := $(GNUPREFIX)objdump
SZ := $(GNUPREFIX)size

# ==== source file dependencies (generated automatically) =====================
DEPS = Dependencies
export DEPENDENCIES_OUTPUT := $(DEPS)

# #### target program name
TARGET = led

# #### source path
SRC_DIR    = ..
COMMON_DIR = ../../common

# #### common object file
COMMON_OBJS  = start.o crt-c.o
## COMMON_OBJS += setjmp.o
COMMON_OBJS += syscalls.o

ifeq ($(BOARD), sim)
    COMMON_OBJS += boot4sim.o
    COMMON_OBJS += divmod.o
endif

# #### C runtime object file
CRTOBJS  = $(CRTOBJPATH)/crtbegin.o
CRTOBJS += $(CRTOBJPATH)/crtend.o
CRTOBJS += $(CRTOBJPATH)/crtn.o

# #### user program object file
OBJS  = led.o 
OBJS += $(COMMON_OBJS)

LIBS = 

# #### source search path
VPATH = $(SRC_DIR):$(COMMON_DIR)

# #### compile option
CPPFLAGS  = -DZPU -DZPUINO_ACCEL
CPPFLAGS += -I$(SRC_DIR) -I$(COMMON_DIR)
CFLAGS    = -c -Wall $(CPPFLAGS)
CFLAGS   += -O2
CFLAGS   += -fno-reorder-blocks  -fno-reorder-blocks-and-partition -fno-prefetch-loop-arrays  -fno-gcse
CFLAGS   += -ffunction-sections -fdata-sections -nostartfiles -mmult -mdiv -mno-callpcrel -mno-pushspadd -mno-poppcrel
LDFLAGS   = -O2 -nostartfiles -Wl,-T -Wl,$(COMMON_DIR)/zpuino.lds -Wl,--relax -Wl,--gc-sections -phi
LDFLAGS2  = $(LIBS) $(CRTOBJS)
ASFLAGS   = -c -g -assembler-with-cpp $(CPPFLAGS) -D_ASM_
OCFLAGS   = -O binary


all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	$(OC) $(OCFLAGS)  $< $@
	$(OD) -D  $< > $(TARGET).dis
	$(OD) -t  $< > $(TARGET).sym

$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS)  $^ $(LDFLAGS2) -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

%.o: %.S
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).dis $(TARGET).sym $(OBJS) $(DEPS)


# ==== generate dependencies ==================================================
$(DEPS): ; touch $(DEPS)
include $(DEPS)
