//###################################################################################
//   Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
//   The following information is considered proprietary and confidential to Facebook,
//   and may not be disclosed to any third party nor be used for any purpose other
//   than to full fill service obligations to Facebook
//###################################################################################
//================================================================================
// Welcome to FNOB!
//================================================================================

//================================================================================
// General question POC: Haoxiang Hu (haoxhu@fb.com); Tuo Wang (tuow@fb.com)

//================================================================================
/////////////////////////////// For users: ///////////////////////////////////////
// Usage of each fnob random type:
fnob_test.sv

// General APIs //
//fnob_db::set     - Create and register fnob variable in fnob_db
//generate a number in [300-100:300+100] that distributed in Gaussian distribution
fnob_db#(bit[63:0])::set("m_fnob_norm", FNOB_NORM, '{"val":'{300, 100}});

//fnob_db::gen - querry the fnob varaible for a random number
fnob_db#(bit[63:0])::gen("m_fnob_norm"))

//fnob_db::val - querry for the fnob varaible for current value
fnob_db#(bit[63:0]::val("m_fnob_norm"))



// Override //

// To override within SV file:
uvm_config_db#(string)::set(null, "*", "<fnob_name>", "<type>:<val_str>");

// To CLI override in TB:
RUNOPTS+="+uvm_set_config_string=\*,m_fnob_profile_delay,profile:0:10:100:1000_5:1"


//================================================================================
/////////////////////////////// For developers: //////////////////////////////////
// To add a new random type
// Step 1: fnob_rand.sv

1.1. create new class extends from fnob_rand#(T), add your random implementation; (follow examples of other classes)
1.2. must have three routines: "new()", "init()", "gen()";

// Step 2: fnob_common.sv

2.1. Add your new random type enum in FNOB_TYPE;
2.2. Add typedef of your new class;
2.3. Add your new enum translation in "param_2_rand" and "s_2_type";

// Step 3: fnob_test.sv

3.1. Create your new fnob in standalone; add comment above instantiation to explain meaning of params;
3.2. Test your new fnob in standalone way:
     3.2.1. Run command at the top of fnob_test.sv
     
3.3. Add your new fnob in "test_override" to test config_db override of new type;

//================================================================================
// Embedded coverage

// Coverage is embedded in each fnob_random_class to check whether all range of values are hit

// To view it under your run path
Verdi -cov -covdir simv.vdb&
