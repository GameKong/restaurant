cmake_minimum_required(VERSION 3.6)

set(APP_NAME encrypt)

project(${APP_NAME})

add_executable(${APP_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp)

# 不依赖 COCOS_X_ROOT 环境变量
set(LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../frameworks/cocos2d-x/external)

set(MACOSX true)
add_subdirectory(${LIBS_DIR}/zlib ${CMAKE_BINARY_DIR}/libs/zlib)
add_subdirectory(${LIBS_DIR}/xxtea ${CMAKE_BINARY_DIR}/libs/xxtea)

target_link_libraries(${APP_NAME} ext_xxtea ext_zlib)