# Copyright (C) 2015 The SaberMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Target arch is arm
TARGET_ARCH := arm

# Find host os
UNAME := $(shell uname -s)

ifeq ($(strip $(UNAME)),Linux)
  HOST_OS := linux
endif

# Only use these compilers on linux host.
ifeq ($(strip $(HOST_OS)),linux)

  USE_CLANG_QCOM := true
  USE_CLANG_QCOM_VERBOSE := true

  # Sabermod configs
  TARGET_NDK_VERSION := 4.9
  TARGET_SM_AND := 4.9
  #use linaro instead of sm
  TARGET_SM_KERNEL := 4.9-linaro
  #TARGET_SM_KERNEL := 4.9
  TOGARI_THREADS := 4
  PRODUCT_THREADS := $(TOGARI_THREADS)

  GRAPHITE_KERNEL_FLAGS := \
    -floop-parallelize-all \
    -ftree-parallelize-loops=$(PRODUCT_THREADS) \
    -fopenmp

  # strict-aliasing kernel flags
  export KERNEL_STRICT_FLAGS := \
           -fstrict-aliasing \
           -Werror=strict-aliasing

  # Enable strict-aliasing kernel flags
#  export CONFIG_MACH_MSM8974_HLTE_STRICT_ALIASING := y
endif

O3_OPTIMIZATIONS := true
ENABLE_PTHREAD := true
STRICT_ALIASING := true

# Make this dependent on "O3_OPTIMIZATIONS := true" for easier configuring and testing.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  DISABLE_O3_OPTIMIZATIONS_THUMB := true
endif

# General flags for gcc 4.9 to allow compilation to complete.
MAYBE_UNINITIALIZED := \
  hwcomposer.msm8974 \
  libbt-brcm_stack

# Extra SaberMod GCC C flags for arch target and Kernel
export EXTRA_SABERMOD_GCC_CFLAGS := \
         -ftree-vectorize \
         -mvectorize-with-neon-quad \
         -pipe

# Flags that should only be used with -O3 optimizations on arch target gcc.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  EXTRA_SABERMOD_GCC_O3_CFLAGS := \
    -ftree-loop-distribution \
    -ftree-loop-if-convert \
    -ftree-loop-im \
    -ftree-loop-ivcanon \
    -fprefetch-loop-arrays
endif

# Extra SaberMod CLANG C flags
EXTRA_SABERMOD_CLANG_CFLAGS := \
  -ftree-vectorize \
  -pipe

# Flags that should only be used with -O3 optimizations on clang.
ifeq ($(strip $(O3_OPTIMIZATIONS)),true)
  EXTRA_SABERMOD_CLANG_O3_CFLAGS := -fprefetch-loop-arrays
endif

OPT4 := (extra)
