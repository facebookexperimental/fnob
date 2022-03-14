`ifndef __FNOB_SV__
 `define __FNOB_SV__

//================================================================================
class fnob#(type T=bit[63:0]) extends uvm_object;

  //`uvm_object_param_utils(fnob#(T))
  
  fnob_rand#(T) m_fnob_rand;
  string        m_fnob_name, m_fnob_rand_name;
  local bit     m_is_set;

  //--------------------------------------------------------------------------------
  function new(string name="", FNOB_TYPE fnob_type, T params[string][$], bit no_name_chk=0);

    super.new(name);
    
    m_fnob_name      = name;
    m_fnob_rand_name = $psprintf("%s_rand", m_fnob_name);
    m_fnob_rand      = fnob_common#(T)::param_2_rand(m_fnob_rand_name, fnob_type, params);
    m_is_set         = 0;

    `uvm_info(get_name(), $psprintf("new %s", m_fnob_name), UVM_NONE)
    if(!no_name_chk)  fnob_common#(T)::fnob_name_add(m_fnob_name);

    // check if initial cfgdb override
    cfgdb_override(m_fnob_name, m_fnob_rand_name, m_fnob_rand);

    fork begin
      // check if future cfgdb override, supports multiple override
      wait_cfgdb_override(m_fnob_name, m_fnob_rand_name, m_fnob_rand);
    end join_none
    
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob#(T) new_multi(string name="", string s);

    fnob_rand#(T) fnob_rand;
    string        fnob_name, fnob_rand_name;
    
    new_multi             = new(name, FNOB_MULTI, '{"val":'{}});
    
    new_multi.m_fnob_rand = fnob_rand_multi#(T)::init(fnob_rand_name, s);

   endfunction

  //--------------------------------------------------------------------------------
  function T gen();

    //gen contains a construct not 
    //supported in constraint functions: driving a non-local variable 'm_gen_val'
    //m_gen_val = m_fnob_rand.gen();
    //return m_gen_val;

    return m_fnob_rand.gen();
    
  endfunction // gen

  //--------------------------------------------------------------------------------
  function T val();

    return m_fnob_rand.m_fnob_gen;
    
  endfunction // gen
  
  //--------------------------------------------------------------------------------
  function bit is_set();

    return m_is_set;
    
  endfunction // gen

  //--------------------------------------------------------------------------------
  function void cfgdb_override(string fnob_name, 
                               string fnob_rand_name,
                               ref fnob_rand#(T) frand);

    string s, s_no_multi;
    T params[string][$];
    FNOB_TYPE fnob_type;

    if (uvm_config_db#(string)::get(null, "", fnob_name, s)) begin
      
      `uvm_info(get_name(), $psprintf("cfg_db override %s", fnob_name), UVM_MEDIUM)
      
      fnob_common#(T)::s_2_param(s, fnob_type, params);
      
      if (fnob_type == FNOB_MULTI) begin
        
        fnob_common#(T)::remove_space_in_str(s);
        s_no_multi  = s.substr(6, (s.len()-1)); // exclude multi:
        
        `uvm_info(get_name(), $psprintf("multi_fnob str s=%s s_no_multi=%s", s, s_no_multi), UVM_MEDIUM)
        frand = fnob_rand_multi#(T)::init(fnob_rand_name, s_no_multi);
      end
      else begin
        frand = fnob_common#(T)::param_2_rand(fnob_rand_name, fnob_type, params);
      end // else: !if(fnob_type == FNOB_MULTI)

      m_is_set = 1;
      
    end
    
  endfunction // cfgdb_override

  //--------------------------------------------------------------------------------
  task wait_cfgdb_override(string fnob_name,
                           string fnob_rand_name,
                           ref fnob_rand#(T) frand);

    forever begin
      
	    uvm_config_db#(string)::wait_modified(null, "", fnob_name);
	    cfgdb_override(fnob_name, fnob_rand_name, frand);
	  end
    
  endtask // wait_cfgdb_override


endclass
`endif
