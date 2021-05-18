#ifndef __AUTO_BIND_TEST_TEST_H__
#define __AUTO_BIND_TEST_TEST_H__

#include "cocos2d.h"

class AutoBindTest : public cocos2d::Ref
{
public:
    AutoBindTest();
    ~AutoBindTest();

    int add(int a, int b);
    int sub(int a, int b);
};

#endif  // __APP_DELEGATE_H__

