cmake_minimum_required(VERSION 2.8)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

project(usb_module)
include("${VITASDK}/share/vita.cmake" REQUIRED)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,-q -Wall -O3 -std=gnu99")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-rtti -fno-exceptions")

include_directories(
)

link_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
)

if (NOT ${RELEASE})
  add_definitions(-DENABLE_LOGGING)
endif()

add_executable(usb_module
  main.c
)

target_link_libraries(usb_module
  taihen_stub
  SceMtpIfDriver_stub
  SceUdcd_stub
  SceUsbstorVStorDriver_stub
  SceShellSvc_stub
  SceLibKernel_stub
  SceKernelThreadMgr_stub
  SceAppMgr_stub_weak
  SceIofilemgr_stub_weak
  SceVshBridge_stub
  SceAppMgr_stub
  SceDisplay_stub
  lua
  z
  m
  c
  stdc++
  #k
  #gcc
)

set_target_properties(usb_module
  PROPERTIES LINK_FLAGS "-nostartfiles" #"-nostdlib"
)

vita_create_self(usb_module.suprx usb_module
  CONFIG ${CMAKE_SOURCE_DIR}/usb_module.yml
)
