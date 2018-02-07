cmake_minimum_required(VERSION 2.8)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

project(adhoc_module)
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

add_executable(adhoc_module
  main.c
)

target_link_libraries(adhoc_module
  taihen_stub
  SceLibKernel_stub
  SceKernelThreadMgr_stub
  SceAppMgr_stub_weak
  SceIofilemgr_stub_weak
  SceVshBridge_stub
  SceDisplay_stub
  vita2d
  lua
  z
  m
  c
  stdc++
  #k
  #gcc
  SceAppMgr_stub
  SceAppUtil_stub
  SceAudio_stub
  soloud
  SceAudiodec_stub
  SceCommonDialog_stub
  SceAVConfig_stub
  SceCtrl_stub
  SceDisplay_stub
  SceGxm_stub
  SceIme_stub
  SceHttp_stub
  SceMtpIfDriver_stub
  SceMusicExport_stub
  SceNet_stub
  SceNetCtl_stub
  SceNpDrm_stub
  SceRegistryMgr_stub
  SceShellSvc_stub
  #SceSqlite_stub
  SceSsl_stub
  SceSysmodule_stub
  ScePgf_stub
  ScePvf_stub 
  ScePhotoExport_stub
  ScePower_stub
  ScePromoterUtil_stub
  SceTouch_stub
  #SceScreenShot_stub
  SceMotion_stub
  SceJpegEnc_stub
  SceCamera_stub
  SceShutterSound_stub
  SceUdcd_stub
  SceUsbstorVStorDriver_stub
  SceVideoExport_stub
  SceVshBridge_stub
  SceHid_stub
  SceKernelDmacMgr_stub
  ScePspnetAdhoc_stub
)

set_target_properties(adhoc_module
  PROPERTIES LINK_FLAGS "-nostartfiles" #"-nostdlib"
)

vita_create_self(adhoc_module.suprx adhoc_module
  CONFIG ${CMAKE_SOURCE_DIR}/adhoc_module.yml
)
