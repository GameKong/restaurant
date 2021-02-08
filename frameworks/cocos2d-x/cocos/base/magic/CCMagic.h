/**
 * Copyright (C) 2015 Droidhang Inc.
 * All Rights Reserved.
 *
 * This is UNPUBLISHED PROPRIETARY SOURCE CODE of Droidhang Inc.
 * The contents of this file may not be disclosed to third parties, copied or
 * duplicated in any form, in whole or in part, without the prior written
 * permission of Droidhang Inc.
 *
 * @brief 用于读取并解密文件。
 * @author Shuai
 * @date 2015-03-027
 */

#ifndef _CC_MAGIC_H_
#define _CC_MAGIC_H_

#include "base/CCData.h"

namespace cocos2d {
    
    class Magic {
    public:
        // 加密有没有生效
        static bool isEnabled();
        
        // 设置密钥
        static void set(const char* key);
        
        // 解密文件，返回解密后的内容；不需要解密则直接返回文件字节流
        static Data get(const std::string& filename);
        
        // 解密字节流，返回解密后的内容；不需要解密则返回NULL
        static Data get(const Data& dataIn);
    };
    
}

#endif //_CC_MAGIC_H_
