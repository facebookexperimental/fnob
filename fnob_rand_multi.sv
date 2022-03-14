`ifndef __FNOB_RAND_MULTI_SV__
 `define __FNOB_RAND_MULTI_SV__

//================================================================================
// put it into separate file and include at last
// make sure all other fnob_rand types are visible to multi

class fnob_rand_multi#(type T=bit[63:0]) extends fnob_rand#(T);

  fnob_rand#(T) m_type_frand;
  fnob_rand#(T) m_val_frand[$];
  int m_ii = 0;
  
  //--------------------------------------------------------------------------------
  function new(string name="", string s);
    
    super.new(name);

    while(s.len() > 0) begin

      T params[string][$];
      FNOB_TYPE fnob_type;
      string s_sub = fnob_common#(T)::get_next_frand(s);

      fnob_common#(T)::s_2_param(s_sub, fnob_type, params);

      if (m_ii == 0) begin
        m_type_frand = fnob_common#(T)::param_2_rand(name, fnob_type, params);
      end
      else begin
        m_val_frand.push_back(fnob_common#(T)::param_2_rand(name, fnob_type, params));
      end
      
      m_ii++;
    end
    
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, string s);
	  fnob_rand_multi#(T) fr = new(name, s);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    int   idx           = m_type_frand.gen();
    fnob_rand#(T) frand = m_val_frand[idx];

    `uvm_info(get_name(), $psprintf("idx=%0d", idx), UVM_NONE)
    return frand.gen();
    
  endfunction // gen

  
endclass

`endif
