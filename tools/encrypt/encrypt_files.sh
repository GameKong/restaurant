#!/bin/bash

# 编译脚本和资源
# 最初来源：encrypt_files_new_x2
# 脚本所在的 publish 目录
PUBLISH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# frameworks/res_raw/src_raw 所在的目录
HOOKHEROES_DIR="${PUBLISH_DIR}/../.."

TMP_DIR="${PUBLISH_DIR}/tmp_crypt"

# 临时文件夹
if [ -d "$TMP_DIR" ]; then
    rm -r $TMP_DIR/*
else
    mkdir -p $TMP_DIR
fi

# 密钥和签名
KEY=D9IOKsTc19nGmSpF
SIGN=DHGAMES
ZSIGN=DHZAMES

# 将错误信息用红色打印
echoError() {
    echo -e "\033[31mError: ${1} \033[0m"
}

# 将普通信息用蓝色打印
echoInfo() {
    echo -e "\033[34mInfo: ${1} \033[0m"
}

# 将重要信息用黄色打印
echoImp() {
    echo -e "\033[33mImp: ${1} \033[0m"
}

# 加密 
encrypt_all() {
    local src="$1"
    local dst="$2"

    # cocos，代码不加密
    if [ "$src" = "${HOOKHEROES_DIR}/src/cocos" ]; then
        return
    fi

    # 音乐，不加密
    if [ "$src" = "${HOOKHEROES_DIR}/res/music" ]; then
        return
    fi

    # db不加密
    if [ "$src" = "${HOOKHEROES_DIR}/res/game.db" ]; then
        return
    fi

    # ccbi资源，不加密
    if [ "$src" = "${HOOKHEROES_DIR}/res/ccbi" ]; then
        return
    fi

    # 文件夹
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        # echoInfo "encrypt files in: $src"
        for name in $(ls "$src"); do
            encrypt_all "$src/$name" "$dst/$name"
        done
        return
    fi

    # 文件
    ${HOOKHEROES_DIR}/tools/encrypt/encrypt $src $dst $KEY $SIGN $ZSIGN
}

# 编译 lua
compile_all() {
    local src="$1"
    local dst="$2"

    # 文件夹
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        # echoInfo "compile files in: $src"
        for name in $(ls "$src"); do
            compile_all "$src/$name" "$dst/$name"
        done
        return
    fi

    # 文件
    ${HOOKHEROES_DIR}/tools/luac -o $dst $src
}

echoImp "start compile and crypt files..."

compile_all ${HOOKHEROES_DIR}/src $TMP_DIR/tmp_src
encrypt_all $TMP_DIR/tmp_src $TMP_DIR/src

# encrypt_all ${HOOKHEROES_DIR}/src $TMP_DIR/src
encrypt_all ${HOOKHEROES_DIR}/res $TMP_DIR/res

# 加密的文件，拷贝过去
echoImp "copy crypt files to res/src..."
rm -rf ${HOOKHEROES_DIR}/src_encrypt
rm -rf ${HOOKHEROES_DIR}/res_encrypt
cp -rf ${TMP_DIR}/src ${HOOKHEROES_DIR}/src_encrypt
cp -rf ${TMP_DIR}/res ${HOOKHEROES_DIR}/res_encrypt

# 不需要加密的文件拷贝过去
cp -rf ${HOOKHEROES_DIR}/src/cocos ${HOOKHEROES_DIR}/src_encrypt/cocos
cp -rf ${HOOKHEROES_DIR}/res/music ${HOOKHEROES_DIR}/res_encrypt/music
cp -rf ${HOOKHEROES_DIR}/res/game.db ${HOOKHEROES_DIR}/res_encrypt/game.db
cp -rf ${HOOKHEROES_DIR}/res/ccbi ${HOOKHEROES_DIR}/res_encrypt/ccbi

# 清除临时目录
rm -rf $TMP_DIR

echoInfo "Encrypt Done!!!"
