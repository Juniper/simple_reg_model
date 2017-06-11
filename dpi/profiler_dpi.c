// DPI Wrapper to call the process profiler information.
#include <sys/time.h>
#include <sys/resource.h>
#include <stdio.h>

extern "C" {
  static FILE* file;
  static int first_time;

  int get_max_resident_ram_size_KB() {
    struct rusage usage;
    int status = getrusage(RUSAGE_SELF, &usage);
    return (status == 0) ? usage.ru_maxrss : 0;
  }

  void profiler_open(const char* scenario) {
    first_time= 1;
    file = fopen("profile.json", "w");
    fprintf(file, "{\n");
    fprintf(file, "   \"scenario\": \"%s\",\n", scenario);
    fprintf(file, "   \"snapshots\": [\n"); 
  }

  void profiler_close() {
    fprintf(file, "\n");
    fprintf(file, "   ]\n");
    fprintf(file, "}\n");
    fclose(file);
  }

  void profiler_snapshot(const char* name) {
    if(!first_time) {
      fprintf(file, ",\n");
    }
    first_time = 0;
    struct rusage usage;
    int status = getrusage(RUSAGE_SELF, &usage);
    if(status == 0) {
      fprintf(file, "      {\n");
      fprintf(file, "         \"name\": \"%s\",\n", name);
      fprintf(file, "         \"utime_sec\": %d,\n", usage.ru_utime.tv_sec);
      fprintf(file, "         \"stime_sec\": %d,\n", usage.ru_stime.tv_sec);
      fprintf(file, "         \"maxrss_KB\": %d\n", usage.ru_maxrss);
      fprintf(file, "      }");
    }
  }
}
