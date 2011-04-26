//
//
// Test.m
//
// By Tom McClean, 2005/2006
//
// This file is public domain. It is provided without any warranty whatsoever,
// and may be modified or used without attribution.
//
//

#include "Test.h"

char lua_script[]="--Put your Lua code to test here";

//
// Prints the contents of the Lua stack, top-down, in human-readable form.
//
// You can use this to check the contents of the stack while debugging Lua code
// through the XCode "Console Log" (in the Debug menu) by typing
// "p print_stack(<whatever_the_relevant_lua_State*_is_called>)".
//

void print_stack(lua_State* interpreter){
	int stack_index=lua_gettop(interpreter);
	for(;stack_index!=0;stack_index--){
		fprintf(stderr,"%d: ",stack_index);
		print_value(interpreter,stack_index,0);
		fprintf(stderr,"\n");
		}
	}

//
// Prints the type and value of the specified item on the Lua stack. The indent
// parameter is used to ensure that items inside nested tables are printed
// nicely, so you can just pass a value of 0 if you're calling this directly.
//

void print_value(lua_State* interpreter,int stack_index,int indent){

	//
	// Use absolute stack indices to make sure we don't get confused later
	//

	if(stack_index<0){
		stack_index=lua_gettop(interpreter)+stack_index+1;
		}

	//
	// Print data about the value
	//

	switch(lua_type(interpreter,stack_index)){
		case LUA_TNIL:{
			fprintf(stderr,"nil");
			break;
			}
		case LUA_TNUMBER:{
			double number=lua_tonumber(interpreter,stack_index);
			if(floor(number)==number){
				fprintf(stderr,"number: %ld",lround(number));
				}
			else{
				fprintf(stderr,"number: %e",number);
				}
			break;
			}
		case LUA_TBOOLEAN:{
			fprintf(stderr,"boolean: %s",lua_toboolean(interpreter,stack_index)?"true":"false");
			break;
			}
		case LUA_TSTRING:{
			fprintf(stderr,"string: \"%s\"",lua_tostring(interpreter,stack_index));
			break;
			}
		case LUA_TTABLE:{
			int i;
			indent++;
			fprintf(stderr,"table: <%p> {",lua_topointer(interpreter,stack_index));

			//
			// Iterate through each key/value pair in the table
			//

			lua_pushnil(interpreter);
			while(lua_next(interpreter,stack_index)!=0){
				fprintf(stderr,"\n");

				//
				// Indent properly
				//

				for(i=0;i<=indent;i++){
					fprintf(stderr,"\t");
					}

				//
				// Print the key/value pair
				//

				print_value(interpreter,-2,indent+1);
				fprintf(stderr," => ");
				print_value(interpreter,-1,indent+1);
				lua_pop(interpreter,1);
				}
			fprintf(stderr,"\n");
			//lua_pop(interpreter,1);

			//
			// Print closing brace
			//

			for(i=0;i<=indent;i++){
				fprintf(stderr,"\t");
				}
			fprintf(stderr,"}");
			break;
			}
		case LUA_TFUNCTION:{
			fprintf(stderr,"function: <%p>",lua_topointer(interpreter,stack_index));
			break;
			}
		case LUA_TUSERDATA:{
			fprintf(stderr,"userdata: <%p>",lua_topointer(interpreter,stack_index));
			break;
			}
		case LUA_TTHREAD:{
			fprintf(stderr,"thread: <%p>",lua_topointer(interpreter,stack_index));
			break;
			}
		case LUA_TNONE:{
			fprintf(stderr,"bad index");
			break;
			}
		default:{
			fprintf(stderr,"unrecognised");
			}
		}
	}

extern int main(int argc,char** argv){

	//
	// Set up Foundation and Lua environments
	//

	NSAutoreleasePool* pool=[[NSAutoreleasePool alloc] init];
	lua_State* interpreter=lua_objc_init();

	//
	// Load and execute a Lua script (comment out if not needed)
	//

	luaL_loadbuffer(interpreter,lua_script,strlen(lua_script),"Main script");
	lua_pcall(interpreter,0,0,0);

	//
	// Put further C code which you want to test here
	//



	//
	// Clean up and exit
	//

	lua_close(interpreter);
	[pool release];
	return 0;
	}