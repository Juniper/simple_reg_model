//
// --------------------------------------------------------------
// Copyright (c) 2017-2023, Juniper Networks, Inc.
// All rights reserved.
//
// This code is licensed to you under the MIT license. 
// You many not use this code except in compliance with this license.
// This code is not an official Juniper product. You may obtain a copy
// of the license at 
//
// https://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is  distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR  CONDITIONS OF ANY KIND, either express or 
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
// -------------------------------------------------------------
//
`ifndef INCLUDED_srm_field_policies_svh
`define INCLUDED_srm_field_policies_svh


// Class: Built In Field Access Policies
// Singleton classes implementing the various accessibility policy of the fields.
//

// Class: srm_rw_policy
//
// Read Write Field
//

class srm_rw_policy extends srm_base_field_policy;
  local static srm_rw_policy _policy;

  // Function new
  //
  // Private constructor for singleton class
  //
  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_rw_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  //
  // Function: get_name
  //
  // Returns the name of the policy.
  //
  virtual function string get_name();
    return "RW";
  endfunction

  //
  // Function: read_policy
  //
  // Update regstore with the read data from design.
  //
  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Update the model.
  endfunction

  //
  // Function: write_policy
  //
  // Update regstore with the data writtedn to design.
  //
  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Write as is
  endfunction

endclass

// Class: srm_ro_policy
//
// Read Only Field
//
class srm_ro_policy extends srm_base_field_policy;
  local static srm_ro_policy _policy;

  // Singleton class so private constructor.
  local function new();
  endfunction

  virtual function string get_name();
    return "RO";
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_ro_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Write has no effect
  endfunction

endclass

// Class: srm_rc_policy
// Read clear Field.
//
// Read clears all the bits in Field. Write has no effect.
//
class srm_rc_policy extends srm_base_field_policy;
  local static srm_rc_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_rc_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "RC";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Skip the update to the model.
  endfunction

endclass

//
// Class: srm_rs_policy
// Read Set Field
//
// Read sets all the bits. Write has no effect.
//
class srm_rs_policy extends srm_base_field_policy;
  local static srm_rs_policy _policy;

  local function new();
  endfunction

  virtual function string get_name();
    return "RS";
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_rs_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Skip the update to the model.
  endfunction

endclass

// Class: srm_wrc_policy
// Write Read Clear Field.
//
// Read clears all the bits. Write as is.
class srm_wrc_policy extends srm_base_field_policy;
  local static srm_wrc_policy _policy;

  local function new();
  endfunction

  virtual function string get_name();
    return "WRC";
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wrc_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction
  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Write as is
  endfunction

endclass

//
// Class: srm_wrs_policy
// Write Read Seta Field. 
//
// Read sets all the bits. Write as is.
class srm_wrs_policy extends srm_base_field_policy;
  local static srm_wrs_policy _policy;

  local function new();
  endfunction
  
  virtual function string get_name();
    return "WRS";
  endfunction


  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wrs_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Write as is
  endfunction

endclass
//
// Class: srm_wc_policy
// Write Clear Field.
//
// Write clears all the bits. Read has no effect.
class srm_wc_policy extends srm_base_field_policy;
  local static srm_wc_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wc_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "WC";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction

endclass

// Class: srm_ws_policy
// Write Set Field.
//
// Write sets all the bits. Read has no effect.
class srm_ws_policy extends srm_base_field_policy;
  local static srm_ws_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_ws_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "WS";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

endclass

// Class: srm_wsrc_policy
// Write Set Read Clear Field.
//
// Write sets all the bits. Read clears all the fields.
class srm_wsrc_policy extends srm_base_field_policy;
  local static srm_wsrc_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wsrc_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "WSRC";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

endclass

// Class: srm_wcrs_policy
// Write Clear Read Set.
//
// Write clears all the bits. Read sets all the bits.
class srm_wcrs_policy extends srm_base_field_policy;
  local static srm_wcrs_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wcrs_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "WCRS";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w1c_policy
// Write 1 Clear Field.
//
// Write 1-clears the bit, 0-no effect, Read: no affect
class srm_w1c_policy extends srm_base_field_policy;
  local static srm_w1c_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w1c_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W1C";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? 'h0 : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w1s_policy
// Write 1-clears the bit, 0-no effect, Read: no affect
class srm_w1s_policy extends srm_base_field_policy;
  local static srm_w1s_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w1s_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W1S";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? 'h1 : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w1t_policy
// Write 1 Set Field.
//
// Write 1-toggles the bit, 0-no effect, Read: no affect
class srm_w1t_policy extends srm_base_field_policy;
  local static srm_w1t_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w1t_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "W1T";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? ~current_byte[j] : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w0c_policy
// Write 0 Clear Field.
//
// Write 1- no effect, 0- clear, Read: no affect
class srm_w0c_policy extends srm_base_field_policy;
  local static srm_w0c_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w0c_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W0C";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = ~new_byte[j] ? 'h0 : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass


// Class: srm_w0s_policy
// Write 0 Set Field.
//
// Write 1- no effect, 0- set, Read: no affect
// 
class srm_w0s_policy extends srm_base_field_policy;
  local static srm_w0s_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w0s_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W0S";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = ~new_byte[j] ? 'h1 : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w0t_policy
// Write 1- no effect, 0- toggle, Read: no affect
class srm_w0t_policy extends srm_base_field_policy;
  local static srm_w0t_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w0t_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "W0T";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Read has no effect.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? current_byte[j]  : ~current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass


// Class: srm_w1src_policy
// Write 1- set effect, 0-no effect , Read: clears 
class srm_w1src_policy extends srm_base_field_policy;
  local static srm_w1src_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w1src_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W1SRC";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++) begin
      bytes[i] = 'h0;
    end
    return 1;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? 'h1  : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w1crs_policy
// Write 1- clear, 0-no effect , Read: sets 
class srm_w1crs_policy extends srm_base_field_policy;
  local static srm_w1crs_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w1crs_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "W1CRS";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++) begin
      bytes[i] = 'hff;
    end
    return 1;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = new_byte[j] ? 'h0  : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction
endclass

// Class: srm_w0src_policy
// Write 1- no effect, 0-sets  , Read: clears 
class srm_w0src_policy extends srm_base_field_policy;
  local static srm_w0src_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w0src_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction

  virtual function string get_name();
    return "W0SRC";
  endfunction

  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++) begin
      bytes[i] = 'h00;
    end
    return 1;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = ~new_byte[j] ? 'h1  : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_w0crs_policy
// Write 1- no effect, 0- clears, Read: sets 
class srm_w0crs_policy extends srm_base_field_policy;
  local static srm_w0crs_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_w0crs_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "W0CRS";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++) begin
      bytes[i] = 'hff;
    end
    return 1;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    reg[7:0] current_byte, new_byte;
    srm_data_t current_value;
    current_value = field.get_bytes();

    for(int i = 0; i < bytes.size(); i++) begin
      current_byte = current_value[i];
      new_byte = bytes[i];
      for(int j = 0; j < 8; j++) begin
        new_byte[j] = ~new_byte[j] ? 'h0  : current_byte[j];
      end
      bytes[i] = new_byte;
    end

    return 1; // Update the model
  endfunction

endclass

// Class: srm_wo_policy
// Write as is, Read: error 
class srm_wo_policy extends srm_base_field_policy;
  local static srm_wo_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wo_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "wo";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    `uvm_error("RegModel", 
          $sformatf("%s field \"%s\" no read allowed in map",
                get_name(), field.get_name()));
    return 0;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 1; // Update the model
  endfunction

endclass

// Class: srm_woc_policy
// Write clears all bits, Read: error 
class srm_woc_policy extends srm_base_field_policy;
  local static srm_woc_policy _policy;

  local function new();
  endfunction

  static function srm_woc_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "woc";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    `uvm_error("RegModel", 
          $sformatf("%s field \"%s\" no read allowed in map",
                get_name(), field.get_name()));
    return 0;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h0;

    return 1; // Update the model
  endfunction

endclass

// Class: srm_wos_policy
// Write sets all bits, Read: error 
class srm_wos_policy extends srm_base_field_policy;
  local static srm_wos_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wos_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "wos";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    `uvm_error("RegModel", 
          $sformatf("%s field \"%s\" no read allowed in map",
                get_name(), field.get_name()));
    return 0;
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'hff;

    return 1; // Update the model
  endfunction

endclass

// Policy for reserved field.
// Write: clear the field, Read : ignored.
class srm_wor_policy extends srm_base_field_policy;
  local static srm_wor_policy _policy;

  local function new();
  endfunction

  // 
  // Static Function: get
  //
  // Constructor for singleton
  //
  static function srm_wor_policy get();
    if(_policy == null) _policy = new();
    return _policy;
  endfunction
  
  virtual function string get_name();
    return "wor";
  endfunction


  virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    return 0; // Do not ignore the model.
  endfunction

  virtual function bit write_policy(srm_base_field field, 
                                        ref srm_data_t bytes);
    for(int i = 0; i < bytes.size(); i++)
      bytes[i] = 'h00;

    return 1; // Update the model
  endfunction

endclass
`endif
