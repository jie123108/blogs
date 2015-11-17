
ALL_OBJS=macro c cpp

all: $(ALL_OBJS)

macro: memory_test_macro.c
	gcc -o $@ $<
c: memory_test_c.c
	gcc -o $@ $<
cpp: memory_test_cpp.cpp 
	g++ -o $@ $<
	
clean:
	@rm -f $(ALL_OBJS)