`ifndef __FNOB_RAND_SV__
 `define __FNOB_RAND_SV__

//================================================================================
//Abstract class, must implement below functions in child class
//1. init
//2. gen
virtual class fnob_rand#(type T=bit[63:0]) extends uvm_object;

  T m_fnob_gen;
  
  //--------------------------------------------------------------------------------
  function new(string name="");
    super.new();
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name);
	  //fnob_rand#(T) fr = new(name);
	  //return fr;
  endfunction // init
  
  //--------------------------------------------------------------------------------
  pure virtual function T gen();
  
endclass // fnob_rand

//================================================================================
//Gaussian disribution
class fnob_rand_norm#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_norm,m_range, m_gen;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_norm = {m_norm};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_norm = params[0];
    m_range = params[1];

    fnob_cg             = new;
    fnob_cg.option.name = name;
    
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_norm#(T) fr = new(name, params);
	  return fr;
  endfunction // init
  
  //--------------------------------------------------------------------------------
  virtual function T gen();
    int pos;
    $display("norm=%0d, range=%0d", m_norm, m_range);
    pos = $dist_normal($urandom, 50, 10);
    if (pos > 100) pos = 100;
    else if (pos < 0) pos = 0;
    //scale pos to actual value
    if(pos > 50)  m_gen = ((pos-50) * 1.0 / 50) * m_range + m_norm;
    else m_gen = m_norm - ((50 - pos) * 1.0 / 50) * m_range;
    fnob_cg.sample();
    
    m_fnob_gen = m_gen;
    return m_gen;
  endfunction // gen
  
endclass // fnob_rand_norm



//================================================================================
//inverted Gaussian disribution
//{val:mean,range} -> generate a number in [mean-range:mean+range]
class fnob_rand_inv_norm#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_norm,m_range, m_gen;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_norm = {m_norm};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_norm = params[0];
    m_range = params[1];

    fnob_cg             = new;
    fnob_cg.option.name = name;
    
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_inv_norm#(T) fr = new(name, params);
	  return fr;
  endfunction // init
  
  //--------------------------------------------------------------------------------
  virtual function T gen();
    int pos;
    $display("norm=%0d, range=%0d", m_norm, m_range);
    pos = $dist_normal($urandom, 50, 10);
    if (pos > 100) pos = 100;
    else if (pos < 0) pos = 0;
    //scale pos to actual value
    if(pos > 50)  m_gen = ((100 - pos) * 1.0 / 50) * m_range + m_norm;
    else m_gen = m_norm - (pos * 1.0 / 50) * m_range;

    fnob_cg.sample();

    m_fnob_gen = m_gen;
    return m_gen;
  endfunction // gen
  
endclass // fnob_rand_inv_norm





//================================================================================
class fnob_rand_unif#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_unif_min, m_unif_max, m_unif_mid, m_gen;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_min = {m_unif_min};
      bins val_max = {m_unif_max};
      bins val_mid = {m_unif_mid};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_unif_min = params[0];
    m_unif_max = params[1];
    m_unif_mid = (m_unif_min + m_unif_max) / 2;

    assert(m_unif_min <= m_unif_max);

    fnob_cg             = new;
    fnob_cg.option.name = name;
    
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_unif#(T) fr = new(name, params);
	  return fr;
  endfunction // init
  
  //--------------------------------------------------------------------------------
  virtual function T gen();
    //$display("min=%0d max=%0d", m_unif_min, m_unif_max);
    m_gen = $urandom_range(m_unif_min, m_unif_max);
    fnob_cg.sample();

    m_fnob_gen = m_gen;
    return m_gen;
  endfunction // gen
  
endclass // fnob_rand_unif

//================================================================================
class fnob_randc_unif#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_unif_min, m_unif_max, m_gen;
  T m_vals[$];

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_all[] = {[m_unif_min : m_unif_max]};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_unif_min         = params[0];
    m_unif_max         = params[1];

    assert(m_unif_min <= m_unif_max);

    fnob_cg             = new;
    fnob_cg.option.name = name;
    
    //create m_vals queue
    init_queue();
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_randc_unif#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();
    if(m_vals.size() == 0) init_queue();
    m_gen = m_vals.pop_front();
    //$display("%p", m_vals);

    fnob_cg.sample();

    m_fnob_gen = m_gen;
    return m_gen;
    
  endfunction // gen
 
  virtual function void init_queue();
    for(int i=m_unif_min; i<=m_unif_max; i=i+1) begin
      m_vals.push_back(i);
    end
    m_vals.shuffle(); 
  endfunction: init_queue

endclass // fnob_randc_unif


//================================================================================
class fnob_rand_profile#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_vals[$], m_probs[$];
  int     m_delay_prof_q[$];
  int     m_burst_cnt = 0;
  int     m_sel;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg(int max_sel);
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_sel{
      bins val_all[] = {[0 : max_sel]};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[string][$]);
    
    super.new(name);
    
    split_val_prob(params, m_vals, m_probs);

    fnob_cg = new(m_probs.size()-1);

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[string][$]);
	  fnob_rand_profile#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  function void split_val_prob(ref T params[string][$], 
                               ref T vals[$], 
                               ref T probs[$]);

    vals               = params["val"];
    probs              = params["prob"];

    assert(vals.size() == 2*probs.size())
      else `uvm_fatal(get_name(), $psprintf("params.size=%0d vals.size=%0d probs.size=%.2f",
                                            params.size(), vals.size(), probs.size()));

    `uvm_info(get_name(), $psprintf("vals=%p probs=%p", vals, probs), UVM_MEDIUM)
    
  endfunction // split_val_prob

  //--------------------------------------------------------------------------------
  virtual function T gen();

    if (m_burst_cnt == 0) begin

      if (m_delay_prof_q.size() == 0) begin
        init_delay_prof_q(m_probs, m_delay_prof_q);
      end
      
      m_sel       = m_delay_prof_q.pop_front();
      m_burst_cnt = get_profile_delay(m_sel, m_vals);
      gen         = get_profile_delay(m_sel, m_vals);

      fnob_cg.sample();
      m_fnob_gen = gen;
      //`uvm_info(get_name(), $psprintf("gen=%0d m_burst_cnt=%0d", gen, m_burst_cnt), UVM_MEDIUM)
	    
	  end
	  else begin
	    m_burst_cnt--;
      m_fnob_gen = 0;
      return 0;
	  end // else: !if(m_burst_cnt == 0)
    
  endfunction // gen

  //--------------------------------------------------------------------------------
  function void init_delay_prof_q(ref T probs[$],
                                  ref int delay_prof_q[$]);

    for (int ii=0; ii<probs.size(); ii++) begin

      //`uvm_info(get_name(), $psprintf("probs[%0d]=%0d", ii, probs[ii]), UVM_MEDIUM)

      repeat(int'(probs[ii])) begin delay_prof_q.push_back(ii); end
    end
    
    delay_prof_q.shuffle();

  endfunction // init_delay_profile_q
  
  //--------------------------------------------------------------------------------
  function int get_profile_delay(int sel,
                                 ref T vals[$]);

    int min_val = vals[sel*2];
    int max_val = vals[sel*2 + 1];

    get_profile_delay = $urandom_range(min_val, max_val);

  endfunction // get_profile_delay

endclass // fnob_rand_unif

//================================================================================
class fnob_rand_const#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_const, m_gen;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_all = {m_const};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_const = params[0];

    fnob_cg = new;

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_const#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();
    m_gen = m_const;
    fnob_cg.sample();

    m_fnob_gen = m_gen;
    return m_gen;
  endfunction // gen
  
endclass

//--------------------------------------------------------------------------------
/*
 You cannot declare an array of an embedded covergroup
 this is an LRM restriction because the covergroup declared in a class is an anonymous type 
 and the covergroup name becomes the instance variable. 
 (See 19.4 Using covergroup in classes in the 1800-2012 LRM) 
 You need define the covergroup outside the class
 
 Define sam cg with diff name for better verdi viewing
*/

covergroup fnob_pattern_cg(int val) with function sample(int cp);
  option.per_instance = 1;
  option.goal         = 100;
  option.comment      = "fnob_cg";

  fnob_rand_cg:coverpoint cp{
    bins val_all = {val};
  }
  
endgroup

covergroup fnob_randc_pattern_cg(int val) with function sample(int cp);
  option.per_instance = 1;
  option.goal         = 100;
  option.comment      = "fnob_cg";

  fnob_rand_cg:coverpoint cp{
    bins val_all = {val};
  }
  
endgroup

covergroup fnob_in_list_cg(int val) with function sample(int cp);
  option.per_instance = 1;
  option.goal         = 100;
  option.comment      = "fnob_cg";

  fnob_rand_cg:coverpoint cp{
    bins val_all = {val};
  }
  
endgroup

//================================================================================
class fnob_rand_pattern#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_vals[$];
  int     m_idx = 0;
  fnob_pattern_cg cg[];
  
  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_vals = params;
    cg = new[m_vals.size()];

    for (int ii=0; ii<m_vals.size(); ii++) begin
      cg[ii] = new(m_vals[ii]);
    end

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_pattern#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    if (m_idx >= m_vals.size()) begin
      m_idx = 0;
    end

    gen = m_vals[m_idx];
    cg[m_idx].sample(gen);
    m_idx++;

    m_fnob_gen = gen;

  endfunction // gen
  
endclass

//================================================================================
class fnob_rand_dist#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_vals[$], m_probs[$];
  int m_probs_sum, m_sel;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg(int max_sel);
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_sel{
      bins val_all[] = {[0 : max_sel]};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[string][$]);
    
    super.new(name);

    split_val_prob(params, m_vals, m_probs);

    m_probs_sum = m_probs.sum();

    fnob_cg = new(m_probs.size()-1);

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[string][$]);
	  fnob_rand_dist#(T) fr = new(name, params);
	  return fr;
  endfunction // init

  //--------------------------------------------------------------------------------
  function void split_val_prob(ref T params[string][$], 
                               ref T vals[$], 
                               ref T probs[$]);

    vals               = params["val"];
    probs              = params["prob"];

    assert(vals.size() == 2*probs.size())
      else `uvm_fatal(get_name(), $psprintf("params.size=%0d vals.size=%0d probs.size=%.2f",
                                            params.size(), vals.size(), probs.size()));

    `uvm_info(get_name(), $psprintf("vals=%p probs=%p", vals, probs), UVM_MEDIUM)
    
  endfunction // split_val_prob

  //--------------------------------------------------------------------------------
  virtual function T gen();

    int   idx  = 0;
    int   dice = $urandom_range(0, m_probs_sum-1) + 1;//offset delta 1

    while(dice > m_probs[idx]) begin
      dice -= m_probs[idx];
      idx++;
    end

    gen = $urandom_range(m_vals[idx*2], m_vals[idx*2+1]);

    m_sel = idx;
    fnob_cg.sample();

    m_fnob_gen = gen;
    
  endfunction // gen
  
endclass // fnob_rand_unif

//================================================================================
class fnob_rand_log#(type T=bit[63:0]) extends fnob_rand#(T);

  real m_min_real, m_max_real, m_min_log, m_max_log;
  int  m_min_int, m_max_int, m_gen;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_gen{
      bins val_all[] = {[m_min_int : m_max_int]};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_min_real = params[0];
    m_max_real = params[1];

    m_min_int = params[0];
    m_max_int = params[1];

    assert(m_min_real <= m_max_real);

    m_min_log = $ln(m_min_real);
    m_max_log = $ln(m_max_real);

    fnob_cg             = new;
    fnob_cg.option.name = name;
        
  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_log#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    real  frac   = $itor($urandom) / $itor('hFFFFFFFF);
    real gen_log = m_min_log + (m_max_log - m_min_log) * frac;

    m_gen        = $rtoi( $exp(gen_log) );
    fnob_cg.sample();

    m_fnob_gen = m_gen;
    return m_gen;
    
  endfunction // gen
  
endclass // fnob_rand_log

//================================================================================
class fnob_rand_sfs#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_slow_min, m_slow_max, m_fast_min, m_fast_max;
  T m_slow_cmin, m_slow_cmax, m_fast_cmin, m_fast_cmax;
  T m_vals[$];

  bit m_is_sfs;
  int m_cov_idx;

  //--------------------------------------------------------------------------------
  covergroup fnob_cg;
    option.per_instance = 1;
    option.goal         = 100;
    option.comment      = "fnob_cg";

    fnob_rand_cg:coverpoint m_cov_idx{
      bins val_all[] = {[1 : 2]};
    }
    
  endgroup // fnob_cg

  //--------------------------------------------------------------------------------
  function new(string name="", T params[string][$], bit is_sfs=1);
    
    super.new(name);
    m_slow_min  = params["val"][0];
    m_slow_max  = params["val"][1];
    m_fast_min  = params["val"][2];
    m_fast_max  = params["val"][3];
    m_slow_cmin = params["prob"][0];
    m_slow_cmax = params["prob"][1];
    m_fast_cmin = params["prob"][2];
    m_fast_cmax = params["prob"][3];
    m_vals      = {};
    m_is_sfs    = is_sfs;

    fnob_cg     = new;

    `uvm_info(get_name(), $psprintf("m_slow_min=%0d m_slow_max=%0d m_fast_min=%0d m_fast_max=%0d m_slow_cmin=%0d m_slow_cmax=%0d m_fast_cmin=%0d m_fast_cmax=%0d",
                                    m_slow_min, m_slow_max, m_fast_min, m_fast_max, m_slow_cmin, m_slow_cmax, m_fast_cmin, m_fast_cmax), UVM_MEDIUM)

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[string][$], bit is_sfs=1);
	  fnob_rand_sfs#(T) fr = new(name, params, is_sfs);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    if (m_vals.size() == 0) begin
      fill_arr();
    end

    gen = m_vals.pop_front();

    if ((gen>=m_slow_min) && (gen<=m_slow_max)) begin
      m_cov_idx = 1;
    end
    else if ((gen>=m_fast_min) && (gen<=m_fast_max)) begin
      m_cov_idx = 2;
    end
    fnob_cg.sample();

    m_fnob_gen = gen;
    
  endfunction // gen

  //--------------------------------------------------------------------------------
  virtual function void fill_arr();

    int m_slow_cnt, m_fast_cnt;

    m_slow_cnt   = $urandom_range(m_slow_cmin, m_slow_cmax);
    m_fast_cnt   = $urandom_range(m_fast_cmin, m_fast_cmax);

    if (m_is_sfs == 1) begin
      repeat (m_slow_cnt) begin
        m_vals.push_back($urandom_range(m_slow_min, m_slow_max));
      end

      repeat (m_fast_cnt) begin
        m_vals.push_back($urandom_range(m_fast_min, m_fast_max));
      end
    end
    else begin
      repeat (m_fast_cnt) begin
        m_vals.push_back($urandom_range(m_fast_min, m_fast_max));
      end
      
      repeat (m_slow_cnt) begin
        m_vals.push_back($urandom_range(m_slow_min, m_slow_max));
      end
    end
    
  endfunction // fill_arr
  
endclass

//================================================================================
class fnob_randc_pattern#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_vals[$];
  T m_vals_gen[$];
  fnob_randc_pattern_cg cg[];
  int m_val2idx[int];
  int     m_idx = 0;

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_vals     = params;
    m_vals_gen = params;

    cg = new[m_vals.size()];

    for (int ii=0; ii<m_vals.size(); ii++) begin
      cg[ii] = new(m_vals[ii]);
      m_val2idx[m_vals[ii]] = ii;
    end

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_randc_pattern#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    //pick m_idx
    m_idx = $urandom_range(0, m_vals_gen.size()-1);
    //cut queue into two queues
    gen = m_vals_gen[m_idx];
    //update queue
    m_vals_gen.delete(m_idx);
    if(m_vals_gen.size() == 0) m_vals_gen = m_vals;

    cg[m_val2idx[gen]].sample(gen);
    m_fnob_gen = gen;
    
  endfunction // gen
  
endclass // fnob_randc_pattern

//--------------------------------------------------------------------------------
class fnob_rand_inside_list#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_vals[$];
  fnob_in_list_cg cg[];
  int m_val2idx[int];
  int     m_idx = 0;

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_vals = params;
    cg     = new[m_vals.size()];
    
    for (int ii=0; ii<m_vals.size(); ii++) begin
      cg[ii] = new(m_vals[ii]);
      m_val2idx[m_vals[ii]] = ii;
    end

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_inside_list#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    //pick m_idx
    m_idx = $urandom_range(0, m_vals.size()-1);
    gen = m_vals[m_idx];

    cg[m_val2idx[gen]].sample(gen);
    m_fnob_gen = gen;
    
  endfunction // gen
  
endclass // fnob_inside_list

//--------------------------------------------------------------------------------
class fnob_rand_intvl#(type T=bit[63:0]) extends fnob_rand#(T);

  T m_min, m_max, m_intvl;

  //--------------------------------------------------------------------------------
  function new(string name="", T params[$]);
    
    super.new(name);

    m_min   = params[0];
    m_max   = params[1];
    m_intvl = params[2];

  endfunction // new

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) init(string name, T params[$]);
	  fnob_rand_intvl#(T) fr = new(name, params);
	  return fr;
  endfunction

  //--------------------------------------------------------------------------------
  virtual function T gen();

    int   intvl_tot = (m_max - m_min) / m_intvl;
    int   intvl_sel = $urandom_range(0, intvl_tot);

    gen = m_min + intvl_sel*m_intvl;
    
  endfunction // gen
  
endclass
`endif
