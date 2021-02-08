#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "zlib.h"
#include "xxtea.h"

// 原文件：mainx2.cpp
void encodeBuf(unsigned char* buf, xxtea_long size) {
    //decode buffer
    int lengthOfKey = 29;
    unsigned char encryptChars[] = { 
        0x3c,0xb5,0x3c,0x7f,0x83,0x94,0xba,
        0x3b,0x2b,0xb2,0x73,0x5b,0xef,0xee,
        0xe2,0xa3,0x3b,0x2b,0xcc,0x66,0x3d,
        0xe5,0x2c,0xd7,0x4d,0x2e,0x17,0xe6,
        0xf3
    };
    int index=0;
    int count = 0;
    while(count<size) {
        buf[count++]^=encryptChars[index++];
        if (index==lengthOfKey) {
            index=7;
        }
    }
}

int main(int argc, char **argv) {
    if (argc != 5 && argc != 6) {
        printf("USAGE: encrypt src dst key sign [zsign]\n");
        exit(1);
    }

    // param
    char* src = argv[1];
    char* dst = argv[2];
    char* key = argv[3];
    unsigned long keyLen = strlen(key);
    char* sign = argv[4];
    unsigned long signLen = strlen(sign);
    char* zsign = NULL;
    unsigned long zsignLen = 0;
    if (argc == 6) { 
        zsign = argv[5]; 
        zsignLen = strlen(zsign);
    }

    // read src file
    FILE* srcFile = fopen(src, "rb");
    fseek(srcFile, 0, SEEK_END);
    unsigned long srcLen = ftell(srcFile);
    rewind(srcFile);
    unsigned char* srcBuf = (unsigned char*) malloc(sizeof(char) * srcLen);
    fread(srcBuf, 1, srcLen, srcFile);
    fclose(srcFile);

    // compress
    if (zsign) {
        unsigned long zLen = compressBound(srcLen);
        unsigned char* zBuf = (unsigned char*) malloc(sizeof(char) * (zsignLen + zLen));
        memcpy(zBuf, zsign, zsignLen);
        compress(zBuf + zsignLen, &zLen, srcBuf, srcLen);
        free(srcBuf);
        srcBuf = zBuf;
        srcLen = zsignLen + zLen;
    }

    // encrypt
    xxtea_long dstLen = 0;
    unsigned char* dstBuf = xxtea_encrypt(srcBuf, srcLen, (unsigned char*) key, keyLen, &dstLen);

    encodeBuf(dstBuf, dstLen);

    // open dst file
    FILE* dstFile = fopen(dst, "wb");

    fwrite(sign, 1, signLen, dstFile);
    fwrite(dstBuf, 1, dstLen, dstFile);

    fclose(dstFile);
    free(srcBuf);
    free(dstBuf);

    return 0;
}
