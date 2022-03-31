//###################################################################################
//   Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
//   The following information is considered proprietary and confidential to Facebook,
//   and may not be disclosed to any third party nor be used for any purpose other
//   than to full fill service obligations to Facebook
//###################################################################################
`ifndef __FNOB_DB_SV__
  `define __FNOB_DB_SV__


class fnob_db#(type T=bit[63:0]) extends uvm_object;

  `uvm_object_utils(fnob_db)
 
  //fnob pool that tracks all fnob vars
  //key is fnob_name
  static fnob#(T) m_fnob_pool[string];   


  function new(string name ="fnob_db");
  	super.new(name);
  endfunction: new

  //used for regular fnob type
  static function void set(string fname, FNOB_TYPE ftype, T param[string][$]);
    `uvm_info("fnob_db", $psprintf("set::%s, type %s, param: %p", fname, ftype, param), UVM_LOW)
    //check if exist in the m_fnob_pool or not
    if (check(fname) == 1) begin
      `uvm_fatal("fnob_db", $psprintf("set:: %s already in the m_fnob_pool", fname))
    end else begin
      fnob#(T) fnob_new;
      //disable name chk, since key check is already implemented in fnob_db
      fnob_new = new(fname, ftype, param, /*no_name_chk*/ 1);
      m_fnob_pool[fname] = fnob_new;
    end
  endfunction: set
  
  //used for fnob multi type
  static function void set_multi(string fname, FNOB_TYPE ftype, string param_s);
    `uvm_info("fnob_db", $psprintf("set::%s, type %s, param_s: %s", fname, ftype, param_s), UVM_LOW)
    //check if exist in the m_fnob_pool or not
    if (check(fname) == 1) begin
      `uvm_fatal("fnob_db", $psprintf("set:: %s already in the m_fnob_pool", fname))
    end else begin
      fnob#(T) fnob_new;
      //disable name chk, since key check is already implemented in fnob_db
      fnob_new =fnob#(T)::new_multi(fname, param_s);
      m_fnob_pool[fname] = fnob_new;
    end
  endfunction: set_multi
  
  static function void update(string fname, FNOB_TYPE ftype, T param[string][$]);
    `uvm_info("fnob_db", $psprintf("update::%s, type %s, param: %p", fname, ftype, param), UVM_LOW)
    //check if exist in the m_fnob_pool or not
    if (check(fname) == 1) begin
      m_fnob_pool.delete(fname);
    end
    //construct and add
    m_fnob_pool[fname] = new(fname, ftype, param, /*no_name_chk*/ 1);
  endfunction: update

  static function fnob#(T) get(string fname);
    if (check(fname) == 0) begin
      `uvm_fatal("fnob_db", $psprintf("check:: %s does not exist in the m_fnob_pool", fname))
    end 
    `uvm_info("fnob_db", $psprintf("get::%s", fname), UVM_LOW)
    return m_fnob_pool[fname];
  endfunction: get

  static function bit check(string fname);
    if(m_fnob_pool.exists(fname)) begin
      `uvm_info("fnob_db", $psprintf("check:: %s exists in the m_fnob_pool", fname), UVM_LOW)
      return 1;
    end else begin
      `uvm_info("fnob_db", $psprintf("check:: %s does not exist in the m_fnob_pool", fname), UVM_LOW)
      return 0;
    end
  endfunction: check
  
  //check certain fnob has cli/inline cfg_db ovrd or not
  static function bit has_ovrd(string fname);
    fnob#(T) fnob_tmp;
    fnob_tmp = get(fname); 
    `uvm_info("fnob_db", $psprintf("has_ovrd:: %s has_ovrd: %0d", fname, fnob_tmp.is_set()), UVM_LOW)
    return fnob_tmp.is_set();
  endfunction: has_ovrd

  static function T gen(string fname);
    fnob#(T) fnob_tmp;
    T gen_val;
    T old_val;
    if (check(fname) == 0) begin
      `uvm_fatal("fnob_db", $psprintf("check:: %s does not exist in the m_fnob_pool", fname))
    end 
    fnob_tmp = m_fnob_pool[fname];
    //old_val = fnob_tmp.m_cur_val;
    gen_val = fnob_tmp.gen();
    //TODO write to fnob trace log, remove cur_val
    //`uvm_info("fnob_db", $psprintf("gen_val_trace:%s, cur_val:0x%h -> new_val:0x%h", fname, old_val, gen_val), UVM_HIGH)
    `uvm_info("fnob_db", $psprintf("gen::%s, val:0x%h", fname, gen_val), UVM_LOW)
    return gen_val;
  endfunction: gen

  static function T val(string fname);
    fnob#(T) fnob_tmp;
    T fval;
    if (check(fname) == 0) begin
      `uvm_fatal("fnob_db", $psprintf("check:: %s does not exist in the m_fnob_pool", fname))
    end 
    fnob_tmp = m_fnob_pool[fname];
    fval = fnob_tmp.val();
    //TODO write to fnob trace log, remove cur_val

    `uvm_info("fnob_db", $psprintf("gen::%s, fval:0x%h", fname, fval), UVM_LOW)
    return fval;
  endfunction: val

  static function void dump();
    foreach(m_fnob_pool[i]) begin
      `uvm_info("fnob_db", $psprintf("dump::%s", i), UVM_LOW)
    end
  endfunction: dump


endclass: fnob_db

`endif 
