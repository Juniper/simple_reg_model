all: libprofiler.so
	echo "done building profiler lib"

libprofiler.so: profiler_dpi.c
	g++ -m64 -fPIC -I$(VCS_HOME)/include -c $<
	g++ -m64 -shared -Wl.-soname,$@ profiler_dpi.o -o $@

clean:
	rm -rf *.o libprofiler.so
