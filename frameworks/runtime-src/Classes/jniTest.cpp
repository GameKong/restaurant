/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include <iostream>
#include <jni.h>
#include <string>
#include "jniTest.h"
#include "cocos2d.h"

USING_NS_CC;
using namespace std;

jniTest::jniTest()
{
}

jniTest::~jniTest()
{

}

extern "C" JNIEXPORT void JNICALL Java_org_cocos2dx_lua_AppActivity_jniTest(JNIEnv*  env, jclass ,  jstring prompt){
    // const char* str;
    // str = env->GetStringUTFChars(prompt, false);
    // // if(str == NULL) {
    // //     return NULL;
    // // }
    auto chartest = env->GetStringUTFChars(prompt, NULL);
    std::string test = chartest;
    // std::cout << test << std::endl;
    __android_log_print(ANDROID_LOG_DEBUG, "cocos2d-x debug info1", "%s", chartest);

}







