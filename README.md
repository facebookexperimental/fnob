<!-- ABOUT THE PROJECT -->
## About The Project

FNOB was firstly introduced in [DVCon.US 2022](https://2022.dvcon.org/press-release-march-8-2022/), and attracted lots of interests from industry.

### TL;DR

“Fnob” as Command-line Dynamic Random Generator, is a novel methodology to improve the implementation of constrained-random, with below advantages compared to conventional constraint syntax:
* It produces less error prone testbench coding by taking advantage of predefined templates of each randomization type, which are flexible to take any number of variable sets. 
* Faster random regression bring-up with the ability to override both random type and value through either in-line or command-line override, instead of additional constraint coding and re-compile. 
* Faster DV coverage closure can be achieved by having embedded Fnob coverage on stimulus side, instead of additional functional coverage coding on checking side.

Use the `fnob_readme.txt` to get started.




<!-- GETTING STARTED -->
## Getting Started

Add `fnob_pkg.sv` file into your compilation flow. 

<!-- USAGE EXAMPLES -->
## Usage

### General APIs
```
//fnob_db::set     - Create and register fnob variable in fnob_db
//generate a number in [300-100:300+100] that distributed in Gaussian distribution
fnob_db#(bit[63:0])::set("m_fnob_norm", FNOB_NORM, '{"val":'{300, 100}});

//fnob_db::gen - querry the fnob varaible for a random number
fnob_db#(bit[63:0])::gen("m_fnob_norm"))

//fnob_db::val - querry for the fnob varaible for current value
fnob_db#(bit[63:0]::val("m_fnob_norm"))
```

Use the `fnob_test.sv` to get more use case examples.


### Override
```
// To override within SV file:
uvm_config_db#(string)::set(null, "*", "<fnob_name>", "<type>:<val_str>");

// To CLI override in TB:
RUNOPTS+="+uvm_set_config_string=\*,m_fnob_profile_delay,profile:0:10:100:1000_5:1"
```



<!-- FOR DEVELOPERS -->
The primary purpose that we open source the project is to engage not just more users, more importantly, developers for the FNOB community. 
Any new random type that is highly reusable that currenlty not supported, we encourage everyone to become a developer and commit it!
### Steps to add a new random type
// Step 1: `fnob_rand.sv`

1.1. create new class extends from `fnob_rand#(T)`, add your random implementation; (follow examples of other classes)

1.2. must have three routines: `new()`, `init()`, `gen()`;
 
// Step 2: `fnob_common.sv `

2.1. Add your new random type enum in `FNOB_TYPE`;

2.2. Add typedef of your new class;

2.3. Add your new enum translation in `param_2_rand` and `s_2_type`;


// Step 3: `fnob_test.sv`

3.1. Create your new fnob in standalone; add comment above instantiation to explain meaning of params;

3.2. Test your new fnob in standalone way:

  3.2.1. Run command at the top of `fnob_test.sv`
  
3.3. Add your new fnob in `test_override` to test config_db override of new type;


<!-- CONTACT -->
## Contact

Haoxiang Hu - haoxhu@fb.com
Tuo Wang - tuow@fb.com
