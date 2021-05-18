#include "base/ccConfig.h"
#ifndef __autobind_h__
#define __autobind_h__

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_all_autobind(lua_State* tolua_S);





#endif // __autobind_h__
