################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../upload/testDotProductStreams.cu 

O_SRCS += \
../upload/testDotProductStreams.o 

OBJS += \
./upload/testDotProductStreams.o 

CU_DEPS += \
./upload/testDotProductStreams.d 


# Each subdirectory must supply rules for building sources it contributes
upload/%.o: ../upload/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 -gencode arch=compute_61,code=sm_61  -odir "upload" -M -o "$(@:%.o=%.d)" "$<"
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


