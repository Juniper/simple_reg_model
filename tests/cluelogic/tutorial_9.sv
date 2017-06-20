//==============================================================================
// tutorial_9.sv (v0.1.0) - Source code for "UVM Tutorial for Candy Lovers" 
//                          Post #9.
//
// The MIT License (MIT)
//
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//==============================================================================

`timescale 1ns/1ns

//------------------------------------------------------------------------------
// Module: jelly_bean_taster
//   This is the DUT.
//------------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_slave_if );
   import jelly_bean_pkg::*;

   reg [2:0] flavor;
   reg [1:0] color;
   reg       sugar_free;
   reg       sour;
   reg [1:0] command;
   reg [1:0] taste;

   initial begin
      flavor     = 0;
      color      = 0;
      sugar_free = 0;
      sour       = 0;
      command    = 0;
      taste      = 0;
   end

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.command == jelly_bean_types::WRITE ) begin
         flavor     <= jb_slave_if.flavor;
         color      <= jb_slave_if.color;
         sugar_free <= jb_slave_if.sugar_free;
         sour       <= jb_slave_if.sour;
//    end else if ( jb_slave_if.command == jelly_bean_types::READ ) begin
//       jb_slave_if.taste <= taste;
      end
   end

   assign jb_slave_if.taste = taste;

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.flavor == jelly_bean_types::CHOCOLATE &&
           jb_slave_if.sour ) begin
         taste <= jelly_bean_types::YUCKY;
      end else if ( jb_slave_if.flavor != jelly_bean_types::NO_FLAVOR ) begin
         taste <= jelly_bean_types::YUMMY;
      end
   end
endmodule: jelly_bean_taster

//------------------------------------------------------------------------------
// Module: top
//------------------------------------------------------------------------------

module top;
   import uvm_pkg::*;

   reg clk;
   
   jelly_bean_if     jb_if( clk );
   jelly_bean_taster jb_taster( jb_if );

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_config_db#( virtual jelly_bean_if )::set( .cntxt( null ), 
                                                    .inst_name( "uvm_test_top" ),
                                                    .field_name( "jb_if" ),
                                                    .value( jb_if ) );
      run_test();
   end
endmodule: top

//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
