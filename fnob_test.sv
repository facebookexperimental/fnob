//###################################################################################
//   Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
//   The following information is considered proprietary and confidential to Facebook,
//   and may not be disclosed to any third party nor be used for any purpose other
//   than to full fill service obligations to Facebook
//###################################################################################

/*
 Test without CLI override:
 vcs -R -sverilog -timescale=1ns/10ps -ntb_opts uvm-1.1 -l fnob.log fnob_test.sv +UVM_TESTNAME=fnob_test
 
 Test with CLI override:
 vcs -R -sverilog -timescale=1ns/10ps -ntb_opts uvm-1.1 -l fnob.log fnob_test.sv +UVM_TESTNAME=fnob_test +uvm_set_config_string=\*,m_fnob_unif,unif:10:100
 */

`ifndef __FNOB_TEST_SV__
 `define __FNOB_TEST_SV__


import uvm_pkg::*;
 `include "uvm_macros.svh"
 `include "fnob_pkg.sv"
import fnob_pkg::*;

//================================================================================
class fnob_test extends uvm_component;

  `uvm_component_utils(fnob_test)

  fnob m_fnob_norm;
  fnob m_fnob_inv_norm;
  fnob m_fnob_unif;
  fnob m_fnob_c_unif;
  fnob m_fnob_multi;
  fnob m_fnob_profile;
  fnob m_fnob_const;
  fnob m_fnob_pattern;
  fnob m_fnob_c_pattern;
  fnob m_fnob_inside_list;
  fnob m_fnob_intvl;
  fnob m_fnob_dist;
  fnob m_fnob_log;
  fnob m_fnob_sfs;
  fnob m_fnob_fsf;

  //--------------------------------------------------------------------------------
  function new(string name = "fnob_test", uvm_component parent);

	  super.new(name, parent);

  endfunction // new

  
  //--------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    
    // norm 
    //+uvm_set_config_string=\*,m_fnob_norm,norm:300:100  
    //generate a number in [300-100:300+100] that distributed in Gaussian distribution
    fnob_db#(bit[63:0])::set("m_fnob_norm", FNOB_NORM, '{"val":'{300, 100}});
    //m_fnob_norm = fnob_db#(bit[63:0])::get("m_fnob_norm");
    
    // inv_norm 
    //+uvm_set_config_string=\*,m_fnob_inv_norm,norm:300:100  
    //generate a number in [300-100:300+100] that distributed in inverted Gaussian distribution
    fnob_db#(bit[63:0])::set("m_fnob_inv_norm", FNOB_INV_NORM, '{"val":'{300, 100}});
    //m_fnob_inv_norm = fnob_db#(bit[63:0])::get("m_fnob_inv_norm");

    // {min, max}
    //+uvm_set_config_string=\*,m_fnob_unif,unif:10:20
    fnob_db#(bit[63:0])::set("m_fnob_unif", FNOB_UNIF, '{"val":'{9, 20}});
    //m_fnob_unif = fnob_db#(bit[63:0])::get("m_fnob_unif");
    
    // {min, max} cyclic random
    //+uvm_set_config_string=\*,m_fnob_c_unif,c_unif:100:200
    fnob_db#(bit[63:0])::set("m_fnob_c_unif", FNOB_C_UNIF, '{"val":'{9, 19}});
    //m_fnob_c_unif = fnob_db#(bit[63:0])::get("m_fnob_c_unif");
    
    /*
     1st queue is val: {profile0_min, profile0_max, profile1_min, profile1_max, ...,}
     2nd queue is prob: {profile0_prob, profile1_prob,...}
     assert(val.size() == prob.size())
     +uvm_set_config_string=\*,m_fnob_profile,profile:0:10:100:1000_5:1
     */
    fnob_db#(bit[63:0])::set("m_fnob_profile", FNOB_PROF, '{"val":'{0,0,1,4,5,10,15,20,25,50},"prob":'{35,25,20,10,5}});
    // {constant_value}
    //+uvm_set_config_string=\*,m_fnob_const,constant:9
    fnob_db#(bit[63:0])::set("m_fnob_const", FNOB_CONST, '{"val":'{15}});
    
    // gen value: 16,7,101,0,56,16,7,101,0,56,16,7,...
    //+uvm_set_config_string=\*,m_fnob_pattern,pattern:9:1:2:100
    fnob_db#(bit[63:0])::set("m_fnob_pattern", FNOB_PATN, '{"val":'{16,7,101,0,56}});
    
    // gen value: 16,7,101,0,56,7,16,101,0,56,16,7,...  cyclic random
    //+uvm_set_config_string=\*,m_fnob_pattern,c_pattern:9:1:2:100
    fnob_db#(bit[63:0])::set("m_fnob_c_pattern", FNOB_C_PATN, '{"val":'{16,7,101,0,56}});
   
    // gen value: 16,7,101,7,101,56,0,16, ... random pick from list
    //+uvm_set_config_string=\*,m_fnob_inside_list,in_list:9:1:2:100
    fnob_db#(bit[63:0])::set("m_fnob_inside_list", FNOB_IN_LIST, '{"val":'{16,7,101,0,56}});

    // value list: min, max, interval;
    // pick random value between min and max based on unit of interval
    // output from '{"val":'{256, 1024, 128}}:
    // 512, 384,...
    // won't be 257, 260 etc.
    //+uvm_set_config_string=\*,m_fnob_intvl,intvl:3:50:5
    fnob_db#(bit[63:0])::set("m_fnob_intvl", FNOB_INTVL, '{"val":'{256, 1024, 128}});
    
    /*
     same output as SV "dist" syntax
     1st queue is val: {dist0_min, dist0_max, dist1_min, dist1_max, ...}
     2nd queue is prob: dist0_prob, dist1_prob,...}
     assert(val.size() == prob.size())
     +uvm_set_config_string=\*,m_fnob_dist,dist:0:10:100:1000_5:1
     */
    fnob_db#(bit[63:0])::set("m_fnob_dist", FNOB_DIST, '{"val":'{10,25,150,160,0,5},"prob":'{2,6,6}});

    /*
     Log distribution random:
     |
     |           _
     |           _
     |          _
     |         _
     |       _
     |     _
     |_________________
     {min,      max}
     +uvm_set_config_string=\*,m_fnob_log,log:9:63
     */
    
    fnob_db#(bit[63:0])::set("m_fnob_log", FNOB_LOG, '{"val":'{15,100}});
    /*
     slow-fast-slow:
     Example:
     Goal: start with 2-4 pkt with 100-200 clk delay/stall, followed by 15-20 pkts with 0-10 clk delay/stall
     1st queue is val: {slow_min,slow_max,fast_min,fast_max}
     2nd queue is prob: {slow_cnt_min,slow_cnt_max,fast_cnt_min,fast_cnt_max}
     +uvm_set_config_string=\*,m_fnob_sfs,sfs:200:500:10:20_2:4:10:15
     */
    fnob_db#(bit[63:0])::set("m_fnob_sfs", FNOB_SFS, '{"val":'{100,200,0,10},"prob":'{2,4,15,20}});
    /*
     fast-slow-fast:
     start with fast pkt then slow
     parameter list same as SFS
     +uvm_set_config_string=\*,m_fnob_sfs,fsf:200:500:10:20_2:4:10:15
     */
    fnob_db#(bit[63:0])::set("m_fnob_fsf", FNOB_FSF, '{"val":'{100,200,0,10},"prob":'{2,4,15,20}});
    
    /*
     multi_fnob is meant to randomly choose between other fnob random type
     1st (unif:0:1): control fnob: defined how to randomly choose the rest random type; 
     max value MUST equal to total random type listed
     
     2nd (unif:20:50): 1st random type to choose from;
     3rd (constant:10): 2nd random type to choose from;
     
     Notice:
     1. Range of control_fnob must be equal to total random type you wish to list;
     Example:
     Goal: uniformly randomly choose between 5 random types;
     Control_fnob: (unif:0:4)
     Complete string: (unif:0:4)(1st random)(2nd random)...(5th random)
     
     +uvm_set_config_string=\*,m_fnob_sfs,multi: (unif: 0:2) ( unif:20: 50)(constant:10 ) (fsf:100:200:0: 10_2:4:3:5)
     */
    fnob_db#(bit[63:0])::set_multi("m_fnob_multi", FNOB_MULTI, "( unif :0: 1  )(unif:20 :50)( constant :10 )");
  
    fnob_common#(bit[63:0])::fnob_name_print();
    
  endfunction // build_phase

  //--------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    test_intvl();
    test_norm();
    test_inv_norm();
    test_unif();
    test_c_unif();
    test_multi();
    test_profile();
    test_const();
    test_pattern();
    test_c_pattern();
    test_inside_list();
    test_dist();
    test_log();
    test_sfs();
    test_fsf();

    // Add your new fnob standalone testing
    // Then add your new fnob type to below test_override
    //test_override();
    
    fnob_db#(bit[63:0])::dump();
    
    phase.drop_objection(this);
    
  endtask // run_phase

  //--------------------------------------------------------------------------------
  task test_intvl();

    repeat (50) begin
    `uvm_info(get_name(), $psprintf("m_fnob_intvl=%0d", fnob_db#(bit[63:0])::gen("m_fnob_intvl")), UVM_NONE)
    end
    
  endtask // test_sfs

  //--------------------------------------------------------------------------------
  task test_sfs();

    repeat (50) begin
    `uvm_info(get_name(), $psprintf("m_fnob_sfs=%0d", fnob_db#(bit[63:0])::gen("m_fnob_sfs")), UVM_NONE)
    end
    
  endtask // test_sfs

  //--------------------------------------------------------------------------------
  task test_fsf();

    repeat (50) begin
    `uvm_info(get_name(), $psprintf("m_fnob_fsf=%0d", fnob_db#(bit[63:0])::gen("m_fnob_fsf")), UVM_NONE)
    end
    
  endtask

  //--------------------------------------------------------------------------------
  task test_log();

    repeat (100) begin
    `uvm_info(get_name(), $psprintf("m_fnob_log=%0d", fnob_db#(bit[63:0])::gen("m_fnob_log")), UVM_NONE)
    end
    
  endtask // test_log
  
  //--------------------------------------------------------------------------------
  task test_dist();

    repeat (20) begin
    `uvm_info(get_name(), $psprintf("m_fnob_dist=%0d", fnob_db#(bit[63:0])::gen("m_fnob_dist")), UVM_NONE)
    end
    
  endtask // test_dist
  
  //--------------------------------------------------------------------------------
  task test_pattern();

    repeat (12) begin
    `uvm_info(get_name(), $psprintf("m_fnob_pattern.gen=%0d", fnob_db#(bit[63:0])::gen("m_fnob_pattern")), UVM_NONE)
  `uvm_info(get_name(), $psprintf("m_fnob_pattern.val=%0d", fnob_db#(bit[63:0])::val("m_fnob_pattern")), UVM_NONE)
    end
    
  endtask // test_pattern
  
  //--------------------------------------------------------------------------------
  task test_c_pattern();

    repeat (12) begin
    `uvm_info(get_name(), $psprintf("m_fnob_c_pattern=%0d", fnob_db#(bit[63:0])::gen("m_fnob_c_pattern")), UVM_NONE)
    end
    
  endtask // test_c_pattern
  
  //--------------------------------------------------------------------------------
  task test_inside_list();

    repeat (20) begin
    `uvm_info(get_name(), $psprintf("m_fnob_inside_list=%0d", fnob_db#(bit[63:0])::gen("m_fnob_inside_list")), UVM_NONE)
    end
    
  endtask // test_c_pattern
  
  //--------------------------------------------------------------------------------
  task test_const();

    repeat (5) begin
    `uvm_info(get_name(), $psprintf("m_fnob_const=%0d", fnob_db#(bit[63:0])::gen("m_fnob_const")), UVM_NONE)
    end
    
  endtask // test_const
  
  //--------------------------------------------------------------------------------
  task test_profile();

    repeat (300) begin
    `uvm_info(get_name(), $psprintf("m_fnob_profile=%0d", fnob_db#(bit[63:0])::gen("m_fnob_profile")), UVM_NONE)
    end
    
  endtask // test_profile
  
  //--------------------------------------------------------------------------------
  task test_multi();

    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_multi=%0d", fnob_db#(bit[63:0])::gen("m_fnob_multi")), UVM_NONE)
    end

  endtask // test_multi
  
  //--------------------------------------------------------------------------------
  task test_norm();
      
    fnob_db#(bit[63:0])::update("m_fnob_norm", FNOB_NORM, '{"val":'{600, 300}});
    //m_fnob_norm = fnob_db#(bit[63:0])::get("m_fnob_norm");
    repeat (2000) begin
      `uvm_info(get_name(), $psprintf("m_fnob_norm.gen=%0d", fnob_db#(bit[63:0])::gen("m_fnob_norm")), UVM_NONE)
      `uvm_info(get_name(), $psprintf("m_fnob_norm.val=%0d", fnob_db#(bit[63:0])::val("m_fnob_norm")), UVM_NONE)
      //`uvm_info(get_name(), $psprintf("m_fnob_norm=%0d", m_fnob_norm.gen()), UVM_NONE)
    end

  endtask // test_norm
  
  //--------------------------------------------------------------------------------
  task test_inv_norm();

    repeat (2000) begin
    `uvm_info(get_name(), $psprintf("m_fnob_inv_norm=%0d", fnob_db#(bit[63:0])::gen("m_fnob_inv_norm")), UVM_NONE)
    end

  endtask // test_inv_norm
  

  //--------------------------------------------------------------------------------
  task test_unif();

    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

  endtask // test_unif
  
  //--------------------------------------------------------------------------------
  task test_c_unif();

    repeat (40) begin
    `uvm_info(get_name(), $psprintf("m_fnob_c_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_c_unif")), UVM_NONE)
    end

  endtask // test_c_unif
  
  //--------------------------------------------------------------------------------
  task test_override();

    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end
    
    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "unif:0:10");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end
    
    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "c_unif:0:20");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "unif:  0xf:'h14");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", " profile:0:1:10:  11:100:101_3:2:1");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "pattern:16:10:98:5");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end
    
    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "c_pattern:16:10:98:5");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "in_list:22:33:44:55:66");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", " dist:100:200:15:20:0: 5_6:2:6  ");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", " constant:10");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "log :5:100");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "sfs: 100:200:0:10_2:4:3:5");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "fsf:100:200:0: 10_2:4:3:5");
    #100ns;
    repeat (10) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end

    uvm_config_db#(string)::set(null, "*", "m_fnob_unif", "  multi: (pattern: 0 :1: 2) ( unif:20: 50)(constant:10 ) (fsf:100:200:0: 10_2:4:3:5)");
    #100ns;
    repeat (30) begin
    `uvm_info(get_name(), $psprintf("m_fnob_unif=%0d", fnob_db#(bit[63:0])::gen("m_fnob_unif")), UVM_NONE)
    end
    
  endtask // test_override
  
endclass // fnob_test

//================================================================================
module tb_top;

  initial begin

    `uvm_info("tb_top", "before run_test", UVM_NONE)
    run_test();
    `uvm_info("tb_top", "after run_test", UVM_NONE)
    #100;
  end
  
endmodule // tb_top

`endif
