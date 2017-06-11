`ifndef INCLUDED_function_chaining_sv
`define INCLUDED_function_chaining_sv

//--------------------------------------------------------
// This example works under vcs but fails for ncsim.
//p.get_child().print_name();
//                 |
//ncvlog: *E,EXPSMC (function_chaining.sv,19|17): expecting a semicolon (';') [10.2.2][10.2(IEEE)].
//--------------------------------------------------------

class child;
  function void print_name();
    $display("My name is child");
  endfunction
endclass

class parent;
  function child get_child();
    child c = new();
    return c;
  endfunction
endclass

program test1;
  parent p;
  initial begin
    p = new();
    p.get_child().print_name();
  end
endprogram

`endif
