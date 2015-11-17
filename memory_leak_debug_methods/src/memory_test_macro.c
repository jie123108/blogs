/*********************************************
 * 公共部分，实际使用时，可以独立成单个文件，
 * 在所有需要使用的地方包含该文件。
 *********************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#if defined(__i386__)
#define PTR_FMT "0x%08x"
#define PTR_CAST(ptr) (unsigned int)ptr
#else
#define PTR_FMT "0x%016x"
#define PTR_CAST(ptr) (unsigned long long)ptr
#endif

 #define MALLOC(size)({\
	void* xxxx =  malloc(size);\
	printf("macro: malloc(%d)is called by %s() in %s:%d addr:"PTR_FMT"\n", \
	                size, __FUNCTION__, __FILE__, __LINE__,PTR_CAST(xxxx));\
	xxxx;})
#define FREE(ptr) ({\
	printf("macro: free() is called by %s() in %s:%d addr:"PTR_FMT"\n", \
	                 __FUNCTION__, __FILE__, __LINE__, PTR_CAST(ptr));\
	free(ptr);\
	})
// ({ }) 是gcc的语句表达式扩展。语句表达式扩展具体用法请自行google!
/*********** 公共部分结束 下面是测试代码 ***********/

char* test1() {
	char* p = (char*)MALLOC(128);
	memset(p,0,128);
	strcpy(p, "test1");
	return p;
}

void test2() {
	char* p = test1();
	FREE(p);
	p = NULL;
}

int main(int argc, char* argv[])
{
	char* p = test1();
	test2();
	return 0;	
}
