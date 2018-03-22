################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../crossCorrelation/testCorrelation.cu 

CPP_SRCS += \
../crossCorrelation/PPM.cpp 

OBJS += \
./crossCorrelation/PPM.o \
./crossCorrelation/testCorrelation.o 

CU_DEPS += \
./crossCorrelation/testCorrelation.d 

CPP_DEPS += \
./crossCorrelation/PPM.d 


# Each subdirectory must supply rules for building sources it contributes
crossCorrelation/%.o: ../crossCorrelation/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 -gencode arch=compute_61,code=sm_61  -odir "crossCorrelation" -M -o "$(@:%.o=%.d)" "$<"
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 --compile  -x c++ -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

crossCorrelation/%.o: ../crossCorrelation/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 -gencode arch=compute_61,code=sm_61  -odir "crossCorrelation" -M -o "$(@:%.o=%.d)" "$<"
	/graphics/opt/opt_Ubuntu16.04/cuda/toolkit_9.0/cuda/bin/nvcc -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_61,code=compute_61 -gencode arch=compute_61,code=sm_61  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


