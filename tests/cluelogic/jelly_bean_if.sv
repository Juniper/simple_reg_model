//------------------------------------------------------------------------------
// Interface: jelly_bean_if
//------------------------------------------------------------------------------
`timescale 1ns/1ns

interface jelly_bean_if( input bit clk );
   logic [2:0] flavor;
   logic [1:0] color;
   logic       sugar_free;
   logic       sour;
   logic [1:0] command;
   logic [1:0] taste;

   //---------------------------------------------------------------------------
   // Clocking Block: master_cb
   //---------------------------------------------------------------------------

   clocking master_cb @ ( posedge clk );
      default input #1ns output #1ns;
      output   flavor, color, sugar_free, sour, command;
      input    taste;
   endclocking: master_cb

   //---------------------------------------------------------------------------
   // Clocking Block: slave_cb
   //---------------------------------------------------------------------------

   clocking slave_cb @ ( posedge clk );
      default input #1ns output #1ns;
      input    flavor, color, sugar_free, sour, command;
      output   taste;
   endclocking: slave_cb

   //---------------------------------------------------------------------------
   // Module Ports:
   //---------------------------------------------------------------------------

   modport master_mp( input clk, taste, 
                      output flavor, color, sugar_free, sour, command );
   modport slave_mp( input clk, flavor, color, sugar_free, sour, command,
                     output taste );
   modport master_sync_mp( clocking master_cb );
   modport slave_sync_mp( clocking slave_cb );
endinterface: jelly_bean_if


