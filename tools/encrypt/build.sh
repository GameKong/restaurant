#!/bin/bash

# 在临时目录构建
mkdir tmp_build
cd tmp_build
cmake ..
make -j2

# 拷贝输出，移除临时目录
cd ..
cp tmp_build/encrypt .
rm -rf tmp_build
