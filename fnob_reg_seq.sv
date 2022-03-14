`ifndef __FNOB_REG_SEQ_SV__
  `define __FNOB_REG_SEQ_SV__

class fnob_reg_seq extends uvm_reg_sequence;

    `uvm_object_utils(fnob_reg_seq)

    uvm_reg_block root_block;
    //for other block level tbs, default_map is set to default_map.
    uvm_reg_map default_map; 

    uvm_reg_field field_aa[string]; //key is field_name, element is uvm_reg_field
    fnob fnobs_field_aa[string]; //key is field_name

    function new(string name ="fnob_reg_seq");
    	super.new(name);
    endfunction: new


    virtual function set_root_block(uvm_reg_block block_in);
      root_block = block_in;
    endfunction: set_root_block

    virtual function void collect_all_reg_fields();
      //travers reg_block and populate all the reg fields
      //only add if type is "RW" or "WO"
      uvm_reg_field reg_fields[$];
      root_block.get_fields(reg_fields);
      //check type
      foreach(reg_fields[i]) begin
        if ((reg_fields[i].get_access() == "RW") || (reg_fields[i].get_access() == "WO")) begin
          `uvm_info(get_full_name(),$sformatf("add %s to field_aa", reg_fields[i].get_full_name()), UVM_MEDIUM)
          field_aa[reg_fields[i].get_name()] = reg_fields[i];
        end
      end
    endfunction: collect_all_reg_fields

    virtual function void create_fnob_fields();
      foreach(field_aa[i]) begin
        fnob fnob_new;
        bit[63:0] reset_val;
        reset_val = field_aa[i].get_reset();
        fnob_new = new({"fnob_", i}, FNOB_UNIF, '{"val":'{reset_val, reset_val}});
        fnobs_field_aa[i] = fnob_new;
      end
    endfunction:create_fnob_fields
    
    virtual function void set_field_vals;
      foreach(field_aa[i]) begin
        bit[63:0] f_val;
        f_val = fnobs_field_aa[i].gen();
        `uvm_info(get_full_name(),$sformatf("set %s to 0x%h", i, f_val), UVM_MEDIUM)
        field_aa[i].set(f_val);
      end
    endfunction: set_field_vals


    virtual task pre_body();
      super.pre_body();
      //collect and add uvm_fields
      collect_all_reg_fields();
      //create fnobs for each filed
      create_fnob_fields();
    endtask: pre_body


    ////////////////////// BODY TASK ////////////////
    virtual task body();
      uvm_status_e status;
      //set vals from fnob
      set_field_vals;
      //update and send to DUT
      root_block.update(status);
    endtask: body
    ////////////////////////////////////////////////

    //helper functions
    virtual function uvm_reg get_reg_by_name(string reg_name, uvm_reg_block root_block);
        return (root_block.get_reg_by_name(reg_name));
    endfunction: get_reg_by_name 

    //not provided by uvm_reg api
    virtual function int get_used_bits(uvm_reg c_reg);
      uvm_reg_field fields[$];
      int total_bits;
      c_reg.get_fields(fields);
      foreach(fields[i]) begin
        total_bits = total_bits + fields[i].get_n_bits();
      end
      return total_bits;
    endfunction: get_used_bits

  endclass: fnob_reg_seq


`endif
