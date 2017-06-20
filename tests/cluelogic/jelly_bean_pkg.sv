
`timescale 1ns/1ns
package jelly_bean_pkg;
  import uvm_pkg::*;

  `include "uvm_macros.svh"

  `include "jelly_bean_types.svh"
  `include "jelly_bean_transaction.svh"
  `include "jelly_bean_reg_block.svh"
  `include "jelly_bean_reg_adapter.svh"
  `include "jelly_bean_reg_predictor.svh"
  `include "jelly_bean_agent_config.svh"
  `include "jelly_bean_env_config.svh"
  `include "jelly_bean_sequence.svh"
  `include "jelly_bean_reg_sequence.svh"
  `include "jelly_bean_sequencer.svh"
  `include "jelly_bean_monitor.svh"
  `include "jelly_bean_driver.svh"
  `include "jelly_bean_agent.svh"
  `include "jelly_bean_fc_subscriber.svh"
  `include "jelly_bean_sb_subscriber.svh"
  `include "jelly_bean_scoreboard.svh"
  `include "jelly_bean_env.svh"
  `include "jelly_bean_base_test.svh"
  `include "jelly_bean_reg_test.svh"
  `include "jelly_bean_reg_hw_reset_test.svh"
endpackage
