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

inline void *malloc_wrapper(size_t size,const char* caller_,const char* file_, int line_)
{
	void* p = malloc(size);
	printf("c: malloc(%d)is called by %s() in %s:%d addr:"PTR_FMT"\n", 
							size, caller_, file_, line_,PTR_CAST(p));
	return p;
}
inline void free_wrapper(void *ptr,const char* caller_,const char* file_, int line_)
{
	printf("c: free() is called by %s() in %s:%d addr:"PTR_FMT"\n", 
							caller_, file_, line_, PTR_CAST(ptr));
	return free(ptr);
}

#undef malloc 
#define malloc(size) malloc_wrapper(size,__FUNCTION__,__FILE__,__LINE__)
#undef free 
#define free(ptr) free_wrapper(ptr, __FUNCTION__,__FILE__,__LINE__)

/*********** 公共部分结束 下面是测试代码 ***********/

char* test1() {
	char* p = (char*)malloc(128);
	memset(p,0,128);
	strcpy(p, "test1");
	return p;
}

void test2() {
	char* p = test1();
	free(p);
	p = NULL;
}

int main(int argc, char* argv[])
{
	char* p = test1();
	test2();
	return 0;	
}
