`ifndef __FNOB_COMMON_SV__
 `define __FNOB_COMMON_SV__

typedef enum{
             FNOB_NORM,
             FNOB_INV_NORM,
             FNOB_UNIF,
             FNOB_C_UNIF,
             FNOB_CONST,
             FNOB_PATN,
             FNOB_C_PATN,
             FNOB_IN_LIST,
             FNOB_INTVL,
             FNOB_DIST,
             FNOB_LOG,
             FNOB_SFS,
             FNOB_FSF,
             FNOB_PROF,
             FNOB_MULTI
             } FNOB_TYPE;

typedef class fnob_rand;
typedef class fnob_rand_norm;
typedef class fnob_rand_inv_norm;
typedef class fnob_rand_unif;
typedef class fnob_randc_unif;
typedef class fnob_rand_profile;
typedef class fnob_rand_const;
typedef class fnob_rand_pattern;
typedef class fnob_randc_pattern;
typedef class fnob_rand_inside_list;
typedef class fnob_rand_intvl;
typedef class fnob_rand_dist;
typedef class fnob_rand_log;
typedef class fnob_rand_sfs;
typedef class fnob_rand_multi;

class fnob_common#(type T=bit[63:0]) extends uvm_object;
  //fnob pools: used to check naming conflict or wrong spelling
  local static bit m_fnob_pool[string];

  //--------------------------------------------------------------------------------
  static function void fnob_name_add(string fnob_name);
    //check exist or not
    if(m_fnob_pool.exists(fnob_name))
      `uvm_fatal("FNOB", $sformatf("fnob %s already exists", fnob_name))
    else
      m_fnob_pool[fnob_name] = 1;
  endfunction: fnob_name_add

  //--------------------------------------------------------------------------------

  static function void fnob_name_chk(string fnob_name);
    //check exist or not
    if(!m_fnob_pool.exists(fnob_name))
      `uvm_fatal("FNOB", $sformatf("no fnob %s found, please check cfg_db override", fnob_name))  
  endfunction: fnob_name_chk

  //--------------------------------------------------------------------------------
  static function void fnob_name_print();
    //check exist or not
    foreach(m_fnob_pool[i])
      `uvm_info("FNOB", $sformatf("fnob_pool %s", i), UVM_LOW)
  endfunction: fnob_name_print

  //--------------------------------------------------------------------------------
  static function fnob_rand#(T) param_2_rand(string fnob_rand_name,
                                             FNOB_TYPE fnob_type,
                                             T params[string][$]);

    `uvm_info("param_2_rand", $psprintf("fnob_type=%s params=%p", fnob_type.name(), params), UVM_MEDIUM)

    case (fnob_type)

      FNOB_NORM:    begin param_2_rand = fnob_rand_norm#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_INV_NORM:begin param_2_rand = fnob_rand_inv_norm#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_UNIF:    begin param_2_rand = fnob_rand_unif#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_C_UNIF:  begin param_2_rand = fnob_randc_unif#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_CONST:   begin param_2_rand = fnob_rand_const#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_PATN:    begin param_2_rand = fnob_rand_pattern#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_C_PATN:  begin param_2_rand = fnob_randc_pattern#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_IN_LIST: begin param_2_rand = fnob_rand_inside_list#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_INTVL:   begin param_2_rand = fnob_rand_intvl#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_DIST:    begin param_2_rand = fnob_rand_dist#(T)::init(fnob_rand_name, params);end
      FNOB_LOG:     begin param_2_rand = fnob_rand_log#(T)::init(fnob_rand_name, params["val"]);end
      FNOB_SFS:     begin param_2_rand = fnob_rand_sfs#(T)::init(fnob_rand_name, params, .is_sfs(1));end
      FNOB_FSF:     begin param_2_rand = fnob_rand_sfs#(T)::init(fnob_rand_name, params, .is_sfs(0));end
      FNOB_PROF:    begin param_2_rand = fnob_rand_profile#(T)::init(fnob_rand_name, params);end
      // FNOB_MULTI: return any type for multi is fine as it will be overriden
      FNOB_MULTI:   begin param_2_rand = fnob_rand_unif#(T)::init(fnob_rand_name, params["val"]);end
      default: begin
        `uvm_fatal("param_2_rand", $psprintf("undefined fnob_type=%0s", fnob_type.name()))
      end

    endcase // case (fnob_type)

  endfunction // param_2_rand

  //--------------------------------------------------------------------------------
  static function FNOB_TYPE s_2_type(string s);

    case(s)
      "norm":        return FNOB_NORM;
      "inv_norm":    return FNOB_INV_NORM;
      "unif":        return FNOB_UNIF;
      "c_unif":      return FNOB_C_UNIF;
      "constant":    return FNOB_CONST;
      "pattern":     return FNOB_PATN;
      "c_pattern":   return FNOB_C_PATN;
      "in_list":     return FNOB_IN_LIST;
      "intvl":       return FNOB_INTVL;
      "dist":        return FNOB_DIST;
      "log":         return FNOB_LOG;
      "sfs":         return FNOB_SFS;
      "fsf":         return FNOB_FSF;
      "profile":     return FNOB_PROF;
      "multi":       return FNOB_MULTI;
      default:   begin
        `uvm_fatal("s_2_type", $psprintf("illegal type=%s", s))
      end
    endcase // case (s)

  endfunction // s_2_type

  //--------------------------------------------------------------------------------
  static function void remove_space_in_str(ref string s, input string m=" ");

    string s_new = "";
    for (int ii=0; ii<s.len(); ii++) begin

      if (string'(s[ii]) != m) begin
        //`uvm_info("remove_space_in_str", $psprintf("s=%s s_new=%s", s, s_new), UVM_MEDIUM)
        s_new = {s_new, s[ii]};
      end
    end

    `uvm_info("remove_space_in_str", $psprintf("s=%s s_new=%s m=%s", s, s_new, m), UVM_MEDIUM)
    s = s_new;

  endfunction // remove_space_in_str

  //--------------------------------------------------------------------------------
  static function void remove_partial_str(ref string s, input string m=" ");

    string s_new = "";
    int    jj = 0;
    for (int ii=0; ii<s.len(); ii++) begin

      if (string'(s[ii]) == string'(m[jj])) begin
        jj++;
        //`uvm_info("remove_space_in_str", $psprintf("s=%s s_new=%s", s, s_new), UVM_MEDIUM)

      end
      else begin
        s_new            = {s_new, s[ii]};
      end
    end

    `uvm_info("remove_partial_str", $psprintf("s=%s s_new=%s m=%s", s, s_new, m), UVM_MEDIUM)
    s = s_new;

  endfunction // remove_partial_str

  //--------------------------------------------------------------------------------
  static function T s_2_val(string s);

    fnob_common#(T)::remove_space_in_str(s);

    // hex: 'h, 0x, 0X
	  if (((s[0] == "'") && (s[1] == "h")) ||
	      ((s[0] == "0") && ((s[1] == "x") || (s[1] == "X")))) begin

      bit [7:0] s_1;
      bit [3:0] v_1;
      int shift = 0;

      for (int ii=(s.len()-1); ii>=2; ii--) begin

        s_1 = s[ii];

        if ((s_1 >= "0") && (s_1 <= "9")) begin
          v_1 = s_1 - "0";
        end
        else if ((s_1 >= "a") && (s_1 <= "f")) begin
          v_1 = s_1 - "a" + 10;
        end
        else if ((s_1 >= "A") && (s_1 <= "F")) begin
          v_1 = s_1 - "A" + 10;
        end
        else begin
          `uvm_fatal("s_2_val", $psprintf("invalid hex value: s=%0s v_1=%0h", s, v_1))
        end

        s_2_val |= v_1 << shift;

        //`uvm_info(get_name(), $psprintf("s[%0d]=%s=%0h s_1=%0h v_1=%0h s_2_val=%h", ii, s[ii], s[ii], s_1, v_1, s_2_val), UVM_MEDIUM)
        shift   += 4;

      end

    end
    // binary: 'b
    else if ((s[0] == "'") && (s[1] == "b")) begin

      bit [7:0] s_1;
      bit [3:0] v_1;
      int shift = 0;

      for (int ii=(s.len()-1); ii>=2; ii--) begin

        s_1 = s[ii];

        if ((s_1 >= "0") && (s_1 <= "1")) begin
          v_1 = s_1 - "0";
        end
        else begin
          `uvm_fatal("s_2_val", $psprintf("invalid binary value: s=%0s v_1=%0b", s, v_1))
        end

        s_2_val |= v_1 << shift;
        shift += 1;
      end
    end
    // decimal
    else begin
      return s.atoi();
    end

  endfunction // s_2_val

  //--------------------------------------------------------------------------------
  static function string qidx_2_qstr(int qidx);

    if (qidx == 0) begin
      return "val";
    end
    else begin
      return "prob";
    end

  endfunction // qidx_2_qstr

  //--------------------------------------------------------------------------------
  static function void s_2_param(string s, ref FNOB_TYPE fnob_type, ref T params[string][$]);

    int qidx = 0;
    int idx  = 0;
    int prev = idx;

    fnob_common#(T)::remove_space_in_str(s);

    // illegal exit
    if (s[0] == ":") begin
      `uvm_fatal("s_2_param", $psprintf("illegal cfgdb str=%s missing type, expected <type>:<val>", s))
    end

    // get type
    while ((idx < s.len()) && (s[idx] != ":")) begin
      idx++;
    end
    fnob_type = fnob_common#(T)::s_2_type(s.substr(0, idx-1));
    idx++;
    prev      = idx;

    // get val
    while (idx < s.len()) begin

      if ((s[idx] == ":") || (s[idx] == "_")) begin
        //`uvm_info("s_2_param", $psprintf("%s", s.substr(prev, idx-1)), UVM_MEDIUM)
        params[fnob_common#(T)::qidx_2_qstr(qidx)].push_back(fnob_common#(T)::s_2_val(s.substr(prev, idx-1)));
        prev       = idx + 1;

        if (s[idx] == "_") begin
          qidx++;
        end
      end

      idx++;
    end
    //`uvm_info("s_2_param", $psprintf("%s", s.substr(prev, idx-1)), UVM_MEDIUM)
    params[fnob_common#(T)::qidx_2_qstr(qidx)].push_back(fnob_common#(T)::s_2_val(s.substr(prev, idx-1))); // last one

  endfunction // s_2_params

  //--------------------------------------------------------------------------------
  static function string get_next_frand(ref string s);

    int   idx = 0;

    fnob_common#(T)::remove_space_in_str(s);

    if (s[0] != "(") begin
      `uvm_fatal("get_next_frand", $psprintf("multi_fnob string must start with ( s=%0s", s))
    end

    while ((idx < s.len()) && (s[idx] != ")")) begin
      idx++;
    end

    get_next_frand = s.substr(1, idx-1);
    s              = s.substr(idx+1, s.len()-1);
    `uvm_info("get_next_frand", $psprintf("get_next_frand=%s s=%0s", get_next_frand, s), UVM_MEDIUM)

  endfunction // get_next_frand

endclass // fnob_common

`endif
