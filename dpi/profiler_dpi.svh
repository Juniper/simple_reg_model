`ifndef INCLUDED_profiler_dpi_svh
`define INCLUDED_profiler_dpi_svh

import "DPI" function int get_max_resident_ram_size_KB();
import "DPI" function void profiler_open(input string scenario);
import "DPI" function void profiler_close();
import "DPI" function void profiler_snapshot(input string name); 
`endif
