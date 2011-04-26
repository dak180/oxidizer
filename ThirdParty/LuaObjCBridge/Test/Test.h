/*
 *
 * Test.h
 *
 * By Tom McClean, 2005/2006
 *
 * This file is public domain. It is provided without any warranty whatsoever,
 * and may be modified or used without attribution.
 *
 */

#import <LuaObjCBridge/LuaObjCBridge.h>

extern void print_stack(lua_State* state);
extern void print_value(lua_State* state,int stack_index,int indent);

extern int main(int argc,char** argv);