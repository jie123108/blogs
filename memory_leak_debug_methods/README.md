#�ڴ�й¶(Memory Leak)�����ֹ���ⷽʽ����
&nbsp;&nbsp;&nbsp;&nbsp;��C���Կ����У��ڴ�й¶���ڴ�й¶����Ǿ��������������顣���ʱ���õķ�����һ������¼��ַ�ʽ�������
* ������飬ͨ����ϸ�����룬�鿴malloc��free��������
* ʹ���ڴ�й¶��⹤�߽��м�⡣���磺valgrind,mtrace�ȵȣ���������һЩ�ǲ���Ҫ�޸�Դ���룬һЩ����Ҫ�޸��������ġ�����ʹ�÷�ʽ���ﲻ�����ۡ�
* �Լ�������ʵ�֣�������Ҫ���۴������Լ�ʵ���ڴ���ķ�ʽ��

## �Լ�ʵ���ڴ�й¶���ļ��ַ�ʽ(linuxƽ̨�²���)
#### 1������malloc��free���Ӧ�ĺ�MALLOC��FREE��Ȼ�����з��估�ͷŶ�ʹ���¶���ĺꡣ*(ʵ��ʵ���л�Ӧ�ô���calloc��realloc)*

Դ���룺 [src/memory_test_macro.c](src/memory_test_macro.c)
```cpp
/*********************************************
 * �������֣�ʵ��ʹ��ʱ�����Զ����ɵ����ļ���
 * ��������Ҫʹ�õĵط��������ļ���
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
// ({ }) ��gcc�������ʽ��չ�������ʽ��չ�����÷�������google!
/*********** �������ֽ��� �����ǲ��Դ��� ***********/

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

```
#### 2: ʵ��malloc��free�İ�װ����malloc_wrapper��free_wrapper��Ȼ��ʹ��\#undef ȡ��ԭ����malloc�������壬Ȼ��ʹ��ʹ��\#define���¶���һ����malloc(ʵ�ʵ�����malloc_wrapper����)���������а�����ͷ�ļ��ĵط������õ�malloc�Ͷ��Զ�ʹ�����Ƕ����malloc�ꡣ

Դ���룺 [src/memory_test_c.c](src/memory_test_c.c)
```cpp
/*********************************************
 * �������֣�ʵ��ʹ��ʱ�����Զ����ɵ����ļ���
 * ��������Ҫʹ�õĵط��������ļ���
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

/*********** �������ֽ��� �����ǲ��Դ��� ***********/

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

```
#### 3: ʹ��C++ʵ��һ��Wrapper�࣬����ʵ�ֿ���ƥ��malloc��free��operator()�������Ȼ��ʹ��\#undef ȡ��ԭ����malloc�������壬Ȼ��ʹ��ʹ��\#define���¶���һ����malloc(ʵ�ʵ�����Wrapper���operator()����)���������а�����ͷ�ļ��ĵط������õ�malloc�Ͷ��Զ�ʹ�����Ƕ����malloc�ꡣʹ�ø÷�ʽ������дϵͳ��new,delete������ʵ�ֶ�new,delete���ڴ�Ĵ���

Դ���룺 [src/memory_test_cpp.cpp](src/memory_test_cpp.cpp)
```cpp
/*********************************************
 * �������֣�ʵ��ʹ��ʱ�����Զ����ɵ����ļ���
 * ��������Ҫʹ�õĵط��������ļ���
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

class Wrapper
{
public:
  Wrapper(const char* caller, const char* file, int line)
    : caller_(caller), file_(file), line_(line)
  {
  }

  void* operator()(size_t size)
  {
    	void* ptr = malloc(size);
   		printf("C++: malloc(%d) is called by %s() in %s:%d addr:"PTR_FMT"\n", 
                        (int)size,caller_, file_, line_,PTR_CAST(ptr));
   		return ptr;
  }

  void operator()(void *ptr)
  {
   		printf("C++: free() is called by %s() in %s:%d addr:"PTR_FMT"\n", 
                        caller_, file_, line_,PTR_CAST(ptr));
		free(ptr);
  }
  
private:
  const char*   caller_;
  const char*  file_;
  int           line_;
};

#undef malloc
#define malloc Wrapper(__FUNCTION__,__FILE__,__LINE__)
#undef free
#define free Wrapper(__FUNCTION__,__FILE__,__LINE__)

/*********** �������ֽ��� �����ǲ��Դ��� ***********/

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

```
>
���룺ͨ��ֱ����дϵͳ��malloc��free�������÷������������ɴ�����Ч����������ʹ�ã����ӵĿⶼ����Ч������һ��ȷ������Ϊû��ʹ�õ��꣬û�м�¼�������߼�����λ�á�

##�����ʹ��˵��
srcĿ¼����Makefile��ʹ��make������������Ӧ�Ŀ�ִ���ļ���
���ϼ���ʾ��������ֱ��ǣ�
* ./macro ���:

```bash
<<<<<<< HEAD
macro: malloc(128)is called by test1() in memory_test_macro.c:31 addr:0x087bb008
macro: malloc(128)is called by test1() in memory_test_macro.c:31 addr:0x087bb090
macro: free() is called by test2() in memory_test_macro.c:39 addr:0x087bb090
=======
macro: malloc(128)is called by test1() in memory_test_macro.c:29 addr:0x082ba008
macro: malloc(128)is called by test1() in memory_test_macro.c:29 addr:0x082ba090
macro: free() is called by test2() in memory_test_macro.c:37 addr:0x082ba090
>>>>>>> 7d143d16cbc8831ea2ddc974c9b4de06446e0517
```

* ./c ���:

```bash
<<<<<<< HEAD
c: malloc(128)is called by test1() in memory_test_c.c:39 addr:0x08a44008
c: malloc(128)is called by test1() in memory_test_c.c:39 addr:0x08a44090
c: free() is called by test2() in memory_test_c.c:47 addr:0x08a44090
=======
c: malloc(128)is called by test1() in memory_test_c.c:37 addr:0x08a55008
c: malloc(128)is called by test1() in memory_test_c.c:37 addr:0x08a55090
c: free() is called by test2() in memory_test_c.c:45 addr:0x08a55090
>>>>>>> 7d143d16cbc8831ea2ddc974c9b4de06446e0517
```

* ./cpp ���:

```bash
<<<<<<< HEAD
C++: malloc(128) is called by test1() in memory_test_cpp.cpp:54 addr:0x0956e008
C++: malloc(128) is called by test1() in memory_test_cpp.cpp:54 addr:0x0956e090
C++: free() is called by test2() in memory_test_cpp.cpp:62 addr:0x0956e090
=======
C++: malloc(128) is called by test1() in memory_test_cpp.cpp:52 addr:0x09c18008
C++: malloc(128) is called by test1() in memory_test_cpp.cpp:52 addr:0x09c18090
C++: free() is called by test2() in memory_test_cpp.cpp:60 addr:0x09c18090
>>>>>>> 7d143d16cbc8831ea2ddc974c9b4de06446e0517
```

ͨ�������Ա�malloc��free�еĵ�ַ�����Ǻ����׾�׷�ٵ����ĸ��ط�������ڴ�й¶�ˡ����������̫�󣬿���д���򵥵Ĺ��߶������־���д����õ��������档


#### ���ڵ�����
* ���ϼ��ַ�ʽ(1,2,3)��ֻ����������Լ�Դ�����з��ֵ�й¶��Ч��������ڴ��ڵ��õ�ĳ�����������ģ����ϼ��ַ�ʽ���޷���������
* Ϊʹʾ���򵥣�����ʵ���ж�ֻʵ����malloc��free��û��ʵ��calloc,realloc�Ĵ���