#内存泄露(Memory Leak)几种手工检测方式讨论
&nbsp;&nbsp;&nbsp;&nbsp;在C语言开发中，内存泄露及内存泄露检测是经常会遇到的事情。这个时候常用的方法，一般就以下几种方式来解决：
* 代码审查，通过仔细检查代码，查看malloc及free配对情况。
* 使用内存泄露检测工具进行检测。比如：valgrind,mtrace等等，他们其中一些是不需要修改源代码，一些是需要修改少许代码的。具体使用方式这里不做讨论。
* 自己代码中实现，本文主要讨论代码中自己实现内存检测的方式。

## 自己实现内存泄露检测的几种方式(linux平台下测试)
#### 1：定义malloc及free相对应的宏MALLOC及FREE，然后所有分配及释放都使用新定义的宏。*(实际实现中还应该处理calloc及realloc)*

源代码： [src/memory_test_macro.c](src/memory_test_macro.c)
```cpp
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

```
#### 2: 实现malloc及free的包装函数malloc_wrapper及free_wrapper，然后使用\#undef 取消原来的malloc函数定义，然后使用使用\#define重新定义一个宏malloc(实际调用了malloc_wrapper函数)。后面所有包含该头文件的地方，调用的malloc就都自动使用我们定义的malloc宏。

源代码： [src/memory_test_c.c](src/memory_test_c.c)
```cpp
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

```
#### 3: 使用C++实现一个Wrapper类，该类实现可以匹配malloc及free的operator()运算符。然后使用\#undef 取消原来的malloc函数定义，然后使用使用\#define重新定义一个宏malloc(实际调用了Wrapper类的operator()函数)。后面所有包含该头文件的地方，调用的malloc就都自动使用我们定义的malloc宏。使用该方式可以重写系统的new,delete函数，实现对new,delete的内存的处理。

源代码： [src/memory_test_cpp.cpp](src/memory_test_cpp.cpp)
```cpp
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

```
>
设想：通过直接重写系统的malloc及free方法。该方法不仅对自由代码有效果，对所有使用，链接的库都会生效。但有一个确定，因为没有使用到宏，没有记录到调用者及调用位置。

##输出及使用说明
src目录下有Makefile，使用make编译后会生成相应的可执行文件。
以上几个示例，输出分别是：
* ./macro 输出:

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

* ./c 输出:

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

* ./cpp 输出:

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

通过分析对比malloc及free中的地址，我们很容易就追踪到是哪个地方分配的内存泄露了。如果数据量太大，可以写个简单的工具对输出日志进行处理，得到分析报告。


#### 存在的问题
* 以上几种方式(1,2,3)都只针对在我们自己源代码中发现的泄露有效果。如果内存在调用的某个库里面分配的，以上几种方式都无法检测出来。
* 为使示例简单，以上实现中都只实现了malloc及free，没有实现calloc,realloc的处理。