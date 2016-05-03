################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
hello_world_sw1.elf.size \

ELFCHECK += \
hello_world_sw1.elf.elfcheck \


# All Target
all: hello_world_sw1.elf secondary-outputs

# Tool invocations
hello_world_sw1.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: MicroBlaze gcc linker'
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -L../../hello_world_sw1_bsp/mb_mcs/lib -mlittle-endian -mcpu=v8.40.a -mxl-soft-mul -Wl,--no-relax -Wl,--gc-sections -o "hello_world_sw1.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

hello_world_sw1.elf.size: hello_world_sw1.elf
	@echo 'Invoking: MicroBlaze Print Size'
	mb-size hello_world_sw1.elf  |tee "hello_world_sw1.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

hello_world_sw1.elf.elfcheck: hello_world_sw1.elf
	@echo 'Invoking: Xilinx ELF Check'
	elfcheck hello_world_sw1.elf -hw ../../mb_mcs_hw/system.xml -pe mb_mcs  |tee "hello_world_sw1.elf.elfcheck"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) hello_world_sw1.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
